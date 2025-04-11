require "json-schema"

module ActiveMcp
  module Tool
    class Base
      class << self
        attr_reader :tool_name_value, :description_value

        def tool_name(value)
          @tool_name_value = value
        end

        def description(value)
          @description_value = value
        end

        def argument(name, type, required: false, description: "", visible: ->(_context) { true })
          @schema ||= default_schema

          @schema["properties"][name.to_s] = {"type" => type.to_s, "visible" => visible}
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

        def render_schema(context)
          return default_schema unless @schema

          {
            "type" => "object",
            "properties" => @schema["properties"].filter do |_k, v|
              v["visible"].call(context)
            end.map { |k, v| [k, v.except("visible")] }.to_h,
            "required" => @schema["required"].filter do |item|
              @schema["properties"][item]["visible"].call(context)
            end
          }
        end
      end

      def initialize
      end

      def validate(args, context)
        return true unless self.class.render_schema(context)

        JSON::Validator.validate!(self.class.render_schema(context), args)
      rescue JSON::Schema::ValidationError => e
        {error: e.message}
      end

      def call(context: {}, **args)
        raise NotImplementedError, "#{self.class.name}#call must be implemented"
      end
    end
  end
end
