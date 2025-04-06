module ActiveMcp
  module Response
    class Initialize
      def self.to_hash(id:, name:, version:)
        {
          body: {
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
          },
          status: 200
        }
      end
    end
  end
end
