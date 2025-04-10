module ActiveMcp
  module Message
    class Resource
      def initialize(role:, resource:)
        @role = role
        @resource = resource
      end

      def to_h
        {
          role: @role,
          content: {
            type: "resource",
            resource: {
              uri: @resource.uri,
              mimeType: @resource.class.mime_type_value,
              text: @resource.content
            }
          }
        }
      end
    end
  end
end
