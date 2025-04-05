module ActiveMcp
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      
      desc "Creates an Active MCP initializer and mounts the engine in your routes"
      
      def create_initializer_file
        template "initializer.rb", "config/initializers/active_mcp.rb"
      end
      
      def update_routes
        route "mount ActiveMcp::Engine, at: '/mcp'"
      end
    end
  end
end
