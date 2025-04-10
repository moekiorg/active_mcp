module ActiveMcp
  module Prompt
    class Base
      class << self
        attr_reader :prompt_name_value, :description_value, :arguments

        def prompt_name(value)
          @prompt_name_value = value
        end

        def description(value)
          @description_value = value
        end

        def argument(name, required: false, description: "", complete: -> {})
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

      def visible?(context: {})
        true
      end

      def messages
        raise NotImplementedError, "#{self.class.name}#messages must be implemented"
      end
    end
  end
end
