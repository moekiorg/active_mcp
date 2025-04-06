require "json-schema"

module ActiveMcp
  class Resource
    class << self
      attr_reader :_description, :schema, :_uri, :_mime_type

      def resource_name
        name ? name.underscore.sub(/_resource$/, "") : ""
      end

      def uri(value)
        @_uri = value
      end

      def description(value)
        @_description = value
      end

      def mime_type(value)
        @_mime_type = value
      end

      def registered_resources
        @registered_resources ||= []
      end

      attr_writer :registered_resources

      def inherited(subclass)
        registered_resources << subclass
      end

      def visible?(auth_info)
        if respond_to?(:authorized?)
          authorized?(auth_info)
        else
          true
        end
      end

      def authorized_resources(auth_info = nil)
        registered_resources.select do |tool_class|
          tool_class.visible?(auth_info)
        end.map do |tool_class|
          {
            uri: tool_class._uri,
            name: tool_class.resource_name,
            mimeType: tool_class._mime_type,
            description: tool_class._description
          }
        end
      end
    end

    def text(auth_info:)
      nil
    end

    def blob(auth_info:)
      nil
    end
  end
end
