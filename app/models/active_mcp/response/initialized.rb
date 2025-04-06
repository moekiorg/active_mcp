module ActiveMcp
  module Response
    class Initialized
      def self.to_hash
        {
          body: {
            jsonrpc: JSON_RPC_VERSION,
            method: Method::INITIALIZED
          },
          status: 200
        }
      end
    end
  end
end
