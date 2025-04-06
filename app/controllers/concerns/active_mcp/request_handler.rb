# frozen_string_literal: true

module ActiveMcp
  module RequestHandler
    extend ActiveSupport::Concern

    included do
      protect_from_forgery with: :null_session
      skip_before_action :verify_authenticity_token
      before_action :authenticate, only: [:index]
    end

    def index
      if json_rpc_request?
        handle_mcp_client_request
      else
        handle_mcp_server_request
      end
    end

    private

    def json_rpc_request?
      params[:jsonrpc].present?
    end

    def handle_mcp_client_request
      @id = params[:id]
      @auth_info = auth_info
      
      case params[:method]
      when Method::INITIALIZE
        render 'active_mcp/initialize', formats: :json
      when Method::INITIALIZED
        render 'active_mcp/initialized', formats: :json
      when Method::CANCELLED
        render 'active_mcp/cancelled', formats: :json
      when Method::RESOURCES_LIST
        @resources = ActiveMcp::Resource.authorized_resources(auth_info)
        @format = :jsonrpc
        render 'active_mcp/resources_list', formats: :json
      when Method::RESOURCES_READ
        @resource = ActiveMcp::ResourceReader.read(params:, auth_info:)
        @format = :jsonrpc
        render 'active_mcp/resources_read', formats: :json
      when Method::TOOLS_LIST
        @tools = ActiveMcp::Tool.authorized_tools(auth_info)
        @format = :jsonrpc
        render 'active_mcp/tools_list', formats: :json
      when Method::TOOLS_CALL
        @tool_result = ActiveMcp::ToolExecutor.execute(params: params, auth_info: auth_info)
        @format = :jsonrpc
        render 'active_mcp/tools_call', formats: :json
      else
        @format = :jsonrpc
        render 'active_mcp/no_method', formats: :json
      end
    end

    def handle_mcp_server_request
      @auth_info = auth_info
      
      case params[:method]
      when Method::RESOURCES_LIST
        @resources = ActiveMcp::Resource.authorized_resources(auth_info)
        @format = :json
        render 'active_mcp/resources_list', formats: :json
      when Method::RESOURCES_READ
        @resource = ActiveMcp::ResourceReader.read(params:, auth_info:)
        @format = :json
        render 'active_mcp/resources_read', formats: :json
      when Method::TOOLS_LIST
        @tools = ActiveMcp::Tool.authorized_tools(auth_info)
        @format = :json
        render 'active_mcp/tools_list', formats: :json
      when Method::TOOLS_CALL
        @tool_result = ActiveMcp::ToolExecutor.execute(params: params, auth_info: auth_info)
        @format = :json
        render 'active_mcp/tools_call', formats: :json
      else
        @format = :json
        render 'active_mcp/no_method', formats: :json
      end
    end

    def authenticate
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

    def auth_info
      @auth_info
    end
  end
end
