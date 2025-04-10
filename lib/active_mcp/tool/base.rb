require "json-schema"

module ActiveMcp
  module Tool
    class Base
      class << self
        attr_reader :tool_name_value, :description_value, :schema

        def tool_name(value)
          @tool_name_value = value
        end

        def description(value)
          @description_value = value
        end

        def argument(name, type, required: false, description: "")
          @schema ||= default_schema

          @schema["properties"][name.to_s] = {"type" => type.to_s}
          @schema["properties"][name.to_s]["description"] = description if description
          @schema["required"] << name.to_s if required
        end

        def default_schema
          {
            "type" => "object",
            "properties" => {},
            "required" => []
          }
        end

        def visible?(context: {})
          true
        end
      end

      def initialize
      end

      def validate(args)
        return true unless self.class.schema

        JSON::Validator.validate!(self.class.schema, args)
      rescue JSON::Schema::ValidationError => e
        {error: e.message}
      end

      def call(context: {}, **args)
        raise NotImplementedError, "#{self.class.name}#call must be implemented"
      end
    end
  end
end
