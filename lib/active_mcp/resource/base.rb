require "json-schema"

module ActiveMcp
  module Resource
    class Base
      class << self
        attr_reader :resource_template_name_value, :description_value, :mime_type_value, :uri_template_value, :schema, :arguments

        def resource_template_name(value)
          @resource_template_name_value = value
        end

        def uri_template(value)
          @uri_template_value = value
        end

        def description(value)
          @description_value = value
        end

        def mime_type(value)
          @mime_type_value = value
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
