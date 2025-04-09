require "json-schema"

module ActiveMcp
  module Resource
    class Base
      class << self
        attr_reader :schema, :arguments

        def mime_type
        end

        def argument(name, complete:)
          @arguments = {}
          @arguments[name] = complete
        end
      end

      def initialize
      end

      def resource_name
      end

      def description
      end

      def visible?(context: {})
        true
      end

      def content
        case text
        when String
          text
        when Hash
          text.to_json
        else
          text.to_s
        end
      end
    end
  end
end
