require "json-schema"

module ActiveMcp
  class Tool
    class << self
      attr_reader :desc, :schema

      def tool_name
        name ? name.underscore.sub(/_tool$/, "") : ""
      end

      def description(value)
        @desc = value
      end

      def property(name, type, required: false, description: nil)
        @schema ||= {
          "type" => "object",
          "properties" => {},
          "required" => []
        }

        @schema["properties"][name.to_s] = {"type" => type.to_s}
        @schema["properties"][name.to_s]["description"] = description if description
        @schema["required"] << name.to_s if required
      end

      def argument(...)
        property(...)
      end

      def registered_tools
        @registered_tools ||= []
      end

      attr_writer :registered_tools

      def inherited(subclass)
        registered_tools << subclass
      end

      def visible?(auth_info)
        true
      end
    end

    def initialize
    end

    def call(**args)
      raise NotImplementedError, "#{self.class.name}#call must be implemented"
    end

    def validate_arguments(args)
      return true unless self.class.schema

      JSON::Validator.validate!(self.class.schema, args)
    rescue JSON::Schema::ValidationError => e
      {error: e.message}
    end
  end
end
