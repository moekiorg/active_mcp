module ActiveMcp
  module Response
    class Initialized
      def self.call
        {
          jsonrpc: JSON_RPC_VERSION,
          method: Method::INITIALIZED
        }
      end
    end
  end
end
