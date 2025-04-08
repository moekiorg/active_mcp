require "json-schema"

module ActiveMcp
  module Resource
    class Base
      class << self
        attr_reader :schema, :arguments

        def argument(name, complete)
          @arguments = {}
          @arguments[name] = complete
        end
      end

      def initialize
      end

      def name
      end

      def description
      end

      def visible?(context: {})
        true
      end
    end
  end
end
