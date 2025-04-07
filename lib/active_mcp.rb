# frozen_string_literal: true

require "jbuilder"
require_relative "active_mcp/version"
require_relative "active_mcp/configuration"
require_relative "active_mcp/schema/base"
require_relative "active_mcp/tool/base"
require_relative "active_mcp/server"

if defined? ::Rails
  require_relative "active_mcp/engine"
  require_relative "active_mcp/controller/base"
end

module ActiveMcp
  JSON_RPC_VERSION = "2.0"
  PROTOCOL_VERSION = "2024-11-05"
end
