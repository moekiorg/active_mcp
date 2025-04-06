module ActiveMcp
  module Response
    module ToolsList
      class Jsonrpc
        def self.call(id:, tools:)
          {
            jsonrpc: JSON_RPC_VERSION,
            id:,
            result: {tools:}
          }
        end
      end
    end
  end
end
