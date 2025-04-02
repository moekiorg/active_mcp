# frozen_string_literal: true

module ActiveMcp
  class BaseController < ActionController::Base
    protect_from_forgery with: :null_session
    skip_before_action :verify_authenticity_token
    before_action :process_authentication, only: [:index]

    def index
      case params[:method]
      when Method::TOOLS_LIST
        render_tools_list
      when Method::TOOLS_CALL
        call_tool(params)
      else
        render json: {error: "Method not found: #{params[:method]}"}, status: 404
      end
    end

    private

    def process_authentication
      auth_header = request.headers["Authorization"]
      if auth_header.present?
        @auth_info = {
          header: auth_header,
          type: if auth_header.start_with?("Bearer ")
                  :bearer
                elsif auth_header.start_with?("Basic ")
                  :basic
                else
                  :unknown
                end,
          token: auth_header.split(" ").last
        }
      end
    end

    def render_tools_list
      tools = Tool.registered_tools.map do |tool_class|
        {
          name: tool_class.tool_name,
          description: tool_class.desc,
          inputSchema: tool_class.schema
        }
      end

      render json: {result: tools}
    end

    def call_tool(params)
      tool_name = params[:name]
      arguments = JSON.parse(params[:arguments] || "{}")

      unless tool_name
        render json: {error: "Invalid params: missing tool name"}, status: 422
        return
      end

      tool_class = Tool.registered_tools.find do |tc|
        tc.tool_name == tool_name
      end

      unless tool_class
        render json: {error: "Tool not found: #{tool_name}"}, status: 404
        return
      end

      tool = tool_class.new
      validation_result = tool.validate_arguments(arguments)

      if validation_result.is_a?(Hash) && validation_result[:error]
        render json: {result: validation_result[:error]}
        return
      end

      begin
        arguments[:auth_info] = @auth_info if @auth_info.present?

        result = tool.call(**arguments.symbolize_keys)
        render json: {result: result}
      rescue => e
        render json: {error: "Error: #{e.message}"}
      end
    end
  end
end
