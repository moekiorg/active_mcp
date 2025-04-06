module ActiveMcp
  module Response
    module ToolsCall
      class Jsonrpc
        def self.call(id:, params:, auth_info:)
          result = ActiveMcp::ToolExecutor.call(params: params[:params], auth_info:)
          {
            jsonrpc: JSON_RPC_VERSION,
            id:,
            result:
          }
        end
      end
    end
  end
end
