module ActiveMcp
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc "Creates an Active MCP initializer"

      def create_initializer_file
        template "initializer.rb", "config/initializers/active_mcp.rb"
      end
    end
  end
end
