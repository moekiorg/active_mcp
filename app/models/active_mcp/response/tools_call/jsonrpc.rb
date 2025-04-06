module ActiveMcp
  module Response
    module ToolsCall
      class Jsonrpc
        def self.call(id:, params:, auth_info:)
          result = Json.call(params: params[:params], auth_info:)
          {
            body: {
              jsonrpc: JSON_RPC_VERSION,
              id:,
              result: {
                content: [
                  {
                    type: "text",
                    text: result[:body][:result]
                  }
                ]
              },
            },
            status: result[:status]
          }
        end
      end
    end
  end
end
