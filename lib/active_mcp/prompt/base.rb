module ActiveMcp
  module Prompt
    class Base
      class << self
        attr_reader :arguments

        def argument(name, required: false, description: nil, complete: ->(){})
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

      def name
      end

      def description
      end

      def visible?(context: {})
        true
      end

      def messages
        raise NotImplementedError, "#{self.class.name}#call must be implemented"
      end
    end
  end
end
