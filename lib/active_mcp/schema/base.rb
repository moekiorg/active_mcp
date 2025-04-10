module ActiveMcp
  module Schema
    class Base
      class << self
        attr_reader :tools, :resources, :prompts

        def tool(value)
          @tools ||= []
          @tools << value
        end

        def resource(value, items: [])
          @resources ||= []
          @resources << {klass: value, items:}
        end

        def prompt(value)
          @prompts ||= []
          @prompts << value
        end
      end

      def initialize(context: {})
        @context = context
      end

      def visible_resources
        visibles = self.class.resources&.filter do |resource|
          !resource[:klass].respond_to?(:visible?) || resource[:klass].visible?(context: @context)
        end
        visibles&.map do |resource|
          resource[:items].map do |item|
            resource[:klass].new(**item)
          end
        end&.flatten || []
      end

      def visible_resource_templates
        visibles = self.class.resources&.filter do |resource|
          resource[:klass].respond_to?(:uri_template) && (!resource[:klass].respond_to?(:visible?) || resource[:klass].visible?(context: @context))
        end
        visibles&.map { _1[:klass] } || []
      end

      def visible_tools
        self.class.tools&.filter do |tool|
          !tool.respond_to?(:visible?) || tool.visible?(context: @context)
        end
      end

      def visible_prompts
        self.class.prompts&.filter do |resource|
          !resource.respond_to?(:visible?) || resource.visible?(context: @context)
        end
      end
    end
  end
end
