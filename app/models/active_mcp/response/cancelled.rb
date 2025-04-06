module ActiveMcp
  module Response
    class Cancelled
      def self.call
        {
          jsonrpc: JSON_RPC_VERSION,
          method: Method::CANCELLED
        }
      end
    end
  end
end
