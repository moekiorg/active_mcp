module ActiveMcp
  module Message
    class Text
      def initialize(role:, text:)
        @role = role
        @text = text
      end

      def to_h
        {
          role: @role,
          content: {
            type: "text",
            text: @text
          }
        }
      end
    end
  end
end
