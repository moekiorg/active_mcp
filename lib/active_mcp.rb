# frozen_string_literal: true

require_relative "active_mcp/version"
require_relative "active_mcp/config"
require_relative "active_mcp/tool"
require_relative "active_mcp/server"

if defined? ::Rails
  require_relative "active_mcp/engine"
end

module ActiveMcp
  JSON_RPC_VERSION = "2.0"
  PROTOCOL_VERSION = "2024-11-05"
end
