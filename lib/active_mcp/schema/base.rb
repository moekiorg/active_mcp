module ActiveMcp
  module Schema
    class Base
      class << self
        attr_reader :resources, :resource_templates, :tools

        def resource(klass)
          @resources ||= []
          @resources << klass

          if klass.class.respond_to?(:uri_template)
            @resource_templates ||= []
            @resource_templates << klass.class unless klass.class.in?(@resource_templates)
          end
        end

        def tool(klass)
          @tools ||= []
          @tools << klass
        end
      end

      def initialize(context: {})
        @context = context
      end

      def resources
        self.class.resources.filter do |resource|
          !resource.respond_to?(:visible?) || resource.visible?(context: @context)
        end
      end

      def resource_templates
        self.class.resource_templates.filter do |template|
          !template.respond_to?(:visible?) || template.visible?(context: @context)
        end
      end

      def tools
        self.class.tools.filter do |tool|
          !tool.respond_to?(:visible?) || tool.visible?(context: @context)
        end
      end
    end
  end
end
