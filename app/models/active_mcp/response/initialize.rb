module ActiveMcp
  module Response
    class Initialize
      def self.call(id:)
        {
          jsonrpc: JSON_RPC_VERSION,
          id:,
          result: {
            protocolVersion: PROTOCOL_VERSION,
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
              name: ActiveMcp.config.server_name,
              version: ActiveMcp.config.server_version
            }
          }
        }
      end
    end
  end
end
