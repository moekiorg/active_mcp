module ActiveMcp
  module Response
    module ToolsList
      class Jsonrpc
        def self.call(id:, tools:)
          {
            body: {
              jsonrpc: JSON_RPC_VERSION,
              id:,
              result: {tools:}
            },
            status: 200
          }
        end
      end
    end
  end
end
