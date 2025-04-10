module ActiveMcp
  module Schema
    class Base
      attr_reader :context

      def initialize(context: {})
        @context = context
      end

      def tools
        []
      end

      def resources
        []
      end

      def prompts
        []
      end

      def visible_resources
        resources&.filter do |resource|
          !resource.respond_to?(:visible?) || resource.visible?(context: @context)
        end
      end

      def visible_resource_templates
        resource_instances = resources&.filter do |resource|
          resource.class.respond_to?(:uri_template) && (!resource.respond_to?(:visible?) || resource.visible?(context: @context))
        end

        resource_instances.map(&:class).uniq
      end

      def visible_tools
        tools&.filter do |tool|
          !tool.respond_to?(:visible?) || tool.visible?(context: @context)
        end
      end

      def visible_prompts
        prompts&.filter do |resource|
          !resource.respond_to?(:visible?) || resource.visible?(context: @context)
        end
      end
    end
  end
end
