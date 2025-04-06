module ActiveMcp
  module Response
    class NoMethod
      def self.call
        {
          error: "Method not found"
        }
      end
    end
  end
end
