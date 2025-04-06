module ActiveMcp
  module Response
    class NoMethod
      def self.call
        {
          body: { error: "Method not found" },
          status: 404
        }
      end
    end
  end
end
