# frozen_string_literal: true

module ActiveMcp
  module RequestHandlable
    extend ActiveSupport::Concern

    private

    def json_rpc_request?
      params[:jsonrpc].present?
    end

    def handle_mcp_client_request
      @id = params[:id]
      
      case params[:method]
      when Method::INITIALIZE
        render 'active_mcp/initialize', formats: :json
      when Method::INITIALIZED
        render 'active_mcp/initialized', formats: :json
      when Method::CANCELLED
        render 'active_mcp/cancelled', formats: :json
      when Method::RESOURCES_LIST
        @resources = schema.resources
        @format = :jsonrpc
        render 'active_mcp/resources_list', formats: :json
      when Method::RESOURCES_TEMPLATES_LIST
        @resource_templates = schema.resource_templates
        @format = :jsonrpc
        render 'active_mcp/resource_templates_list', formats: :json
      when Method::RESOURCES_READ
        @resource = read_resource(params:, context:)
        @format = :jsonrpc
        render 'active_mcp/resources_read', formats: :json
      when Method::TOOLS_LIST
        @tools = schema.tools
        @format = :jsonrpc
        render 'active_mcp/tools_list', formats: :json
      when Method::TOOLS_CALL
        @tool_result = execute_tool(params:, context:)
        @format = :jsonrpc
        render 'active_mcp/tools_call', formats: :json
      when Method::COMPLETION_COMPLETE
        type = params.dig(:params, :ref, :type)
        @completion = ActiveMcp::Completion.new.complete(params: params[:params], context:, refs: type === "ref/resource" ? schema.resource_templates : [])
        @format = :jsonrpc
        render "active_mcp/completion_complete", formats: :json
      else
        @format = :jsonrpc
        render 'active_mcp/no_method', formats: :json
      end
    end

    def handle_mcp_server_request
      case params[:method]
      when Method::RESOURCES_LIST
        @resources = schema.resources
        @format = :json
        render 'active_mcp/resources_list', formats: :json
      when Method::RESOURCES_READ
        @resource = read_resource(params:, context:)
        @format = :json
        render 'active_mcp/resources_read', formats: :json
      when Method::RESOURCES_TEMPLATES_LIST
        @resource_templates = schema.resource_templates
        @format = :json
        render 'active_mcp/resource_templates_list', formats: :json
      when Method::TOOLS_LIST
        @tools = schema.tools
        @format = :json
        render 'active_mcp/tools_list', formats: :json
      when Method::TOOLS_CALL
        @tool_result = execute_tool(params:, context:)
        @format = :json
        render 'active_mcp/tools_call', formats: :json
      when Method::COMPLETION_COMPLETE
        type = params.dig(:params, :ref, :type)
        @completion = ActiveMcp::Completion.new.complete(params: params[:params], context:, refs: type == "ref/resource" ? schema.resource_templates : [])
        @format = :json
        render "active_mcp/completion_complete", formats: :json
      else
        @format = :json
        render 'active_mcp/no_method', formats: :json
      end
    end

    def context
      @context ||= {}
    end
  end
end
