# frozen_string_literal: true

require_relative "../concerns/active_mcp/authenticatable"
require_relative "../concerns/active_mcp/request_handlable"
require_relative "../concerns/active_mcp/resource_readable"
require_relative "../concerns/active_mcp/tool_executable"

module ActiveMcp
  class BaseController < ActionController::Base
    include ::ActiveMcp::RequestHandlable
    include ::ActiveMcp::ResourceReadable
    include ::ActiveMcp::ToolExecutable
    include ::ActiveMcp::Authenticatable

    protect_from_forgery with: :null_session
    skip_before_action :verify_authenticity_token
    before_action :authenticate, only: [:index]

    def index
      if json_rpc_request?
        handle_mcp_client_request
      else
        handle_mcp_server_request
      end
    end

    private

    def schema
      nil
    end

    attr_reader :context
  end
end
