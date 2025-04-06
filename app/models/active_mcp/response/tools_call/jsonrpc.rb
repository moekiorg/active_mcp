module ActiveMcp
  module Response
    module ToolsCall
      class Jsonrpc
        def self.call(id:, params:, auth_info:)
          result = Json.call(params: params[:params], auth_info:)
          content = {
            type: "text",
            text: result[:body][:result]
          }
          if result[:isError]
            content[:isError] = true
          end
          {
            body: {
              jsonrpc: JSON_RPC_VERSION,
              id:,
              result: { content: [content] },
            },
            status: result[:status]
          }
        end
      end
    end
  end
end
