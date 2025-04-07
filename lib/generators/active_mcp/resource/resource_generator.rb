module ActiveMcp
  module Generators
    class ResourceGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      def create_resource_file
        template "resource.rb.erb", File.join("app/mcp/resources", "#{file_name}_resource.rb")
      end

      private

      def class_name
        "#{file_name.camelize}Resource"
      end
    end
  end
end
