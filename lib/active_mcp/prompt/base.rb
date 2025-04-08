module ActiveMcp
  module Prompt
    class Base
      class << self
        attr_reader :arguments

        def argument(name, required: false, description: nil, complete: -> {})
          @arguments ||= []

          @arguments << {
            name:,
            description:,
            required:,
            complete:
          }
        end
      end

      def initialize(*args, context: {})
      end

      def prompt_name
      end

      def description
      end

      def visible?(context: {})
        true
      end

      def messages
        raise NotImplementedError, "#{self.class.name}#messages must be implemented"
      end
    end
  end
end
