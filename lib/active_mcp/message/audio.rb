module ActiveMcp
  module Message
    class Audio
      def initialize(role:, data:, mime_type:)
        @role = role
        @data = data
        @mime_type = mime_type
      end

      def to_h
        {
          role: @role,
          content: {
            type: "audio",
            data: Base64.strict_encode64(@data),
            mimeType: @mime_type
          }
        }
      end
    end
  end
end
