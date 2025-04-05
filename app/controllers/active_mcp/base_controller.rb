# frozen_string_literal: true

module ActiveMcp
  class BaseController < ActionController::Base
    protect_from_forgery with: :null_session
    skip_before_action :verify_authenticity_token
    before_action :process_authentication, only: [:index]

    def index
      case params[:method]
      when Method::INITIALIZE
        render_initialize
      when Method::INITIALIZED
        render json: {
          jsonrpc: "2.0",
          method: "notifications/initialized"
        }
      when Method::CANCELLED
        render json: {
          jsonrpc: "2.0",
          method: "notifications/cancelled"
        }
      when Method::TOOLS_LIST
        if params[:jsonrpc]
          render_tools_list_as_jsonrpc
        else
          render_tools_list
        end
      when Method::TOOLS_CALL
        if params[:jsonrpc]
          call_tool_as_jsonrpc
        else
          render json: call_tool(params)
        end
      else
        render json: {error: "Method not found: #{params[:method]}"}, status: 404
      end
    end

    private

    def render_tools_list_as_jsonrpc
      render json: {
        jsonrpc: "2.0",
        id: params[:id],
        result: {tools:}
      }
    end

    def call_tool_as_jsonrpc
      render json: {
        jsonrpc: "2.0",
        id: params[:id],
        result: {
          content: [
            {
              type: "text",
              text: call_tool(params[:params])[:result]
            }
          ]
        }
      }
    end

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

    def render_initialize
      render json: {
          jsonrpc: "2.0",
          id: params[:id],
          result: {
            protocolVersion: "2024-11-05",
            capabilities: {
              logging: {},
              capabilities: {
                resources: {
                  subscribe: false,
                  listChanged: false
                },
                tools: {
                  listChanged: false
                }
              },
            },
            serverInfo: {
              name: ActiveMcp::Configuration.config.server_name,
              version: ActiveMcp::Configuration.config.server_version
            }
          }
        }
    end

    def render_tools_list
      render json: {result: tools}
    end

    def tools
      Tool.registered_tools.select do |tool_class|
        tool_class.authorized?(@auth_info)
      end.map do |tool_class|
        {
          name: tool_class.tool_name,
          description: tool_class.desc,
          inputSchema: tool_class.schema
        }
      end
    end

    def call_tool(params)
      tool_name = params[:name]

      unless tool_name
        return {error: "Invalid params: missing tool name"}
      end

      tool_class = Tool.registered_tools.find do |tc|
        tc.tool_name == tool_name
      end

      unless tool_class
        return {error: "Tool not found: #{tool_name}"}
      end

      unless tool_class.authorized?(@auth_info)
        return {error: "Unauthorized: Access to tool '#{tool_name}' denied"}
      end

      if params[:arguments].is_a?(Hash)
        arguments = params[:arguments].symbolize_keys
      else
        arguments = params[:arguments].permit!.to_hash.symbolize_keys.transform_values { _1.match(/^\d+$/) ? _1.to_i : _1 }
      end

      tool = tool_class.new
      validation_result = tool.validate_arguments(arguments)

      if validation_result.is_a?(Hash) && validation_result[:error]
        return {result: validation_result[:error]}
      end

      begin
        arguments[:auth_info] = @auth_info if @auth_info.present?

        result = tool.call(**arguments.symbolize_keys)

        return {result: result}
      rescue => e
        return {error: "Error: #{e.message}"}
      end
    end
  end
end
