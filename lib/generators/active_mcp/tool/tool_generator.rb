module ActiveMcp
  module Generators
    class ToolGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      def create_tool_file
        template "tool.rb.erb", File.join("app/tools", "#{file_name}_tool.rb")
      end

      private

      def class_name
        "#{file_name.camelize}Tool"
      end
    end
  end
end
