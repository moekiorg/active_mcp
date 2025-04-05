#!/usr/bin/env ruby
# MCP Server script for Active MCP
require 'active_mcp'

# Load Rails application
ENV['RAILS_ENV'] ||= 'development'
require File.expand_path('../config/environment', __dir__)

# Initialize MCP server
server = ActiveMcp::Server.new(
  name: "<%= Rails.application.class.module_parent_name %> MCP Server",
  uri: '<%= Rails.application.config.action_controller.default_url_options&.fetch(:host, 'http://localhost:3000') %>/mcp'
)

# Optional authentication
<% if ActiveMcp.config.auth_enabled %>
server.auth = {
  type: :bearer,
  token: ENV['MCP_AUTH_TOKEN'] || '<%= ActiveMcp.config.auth_token %>'
}
<% end %>

# Start the server
puts "Starting MCP server for <%= Rails.application.class.module_parent_name %>..."
puts "Connect to this server in MCP clients using the following configuration:"
puts
puts "   Command: #{File.expand_path(__FILE__)}"
puts "   Args: []"
puts
puts "Press Ctrl+C to stop the server"
server.start
