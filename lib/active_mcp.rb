# frozen_string_literal: true

require "jbuilder"
require_relative "active_mcp/version"
require_relative "active_mcp/configuration"
require_relative "active_mcp/schema/base"
require_relative "active_mcp/tool/base"
require_relative "active_mcp/resource/base"
require_relative "active_mcp/prompt/base"
require_relative "active_mcp/message/text"
require_relative "active_mcp/message/image"
require_relative "active_mcp/message/audio"
require_relative "active_mcp/message/resource"
require_relative "active_mcp/server"
require_relative "active_mcp/completion"

if defined? ::Rails
  require_relative "active_mcp/engine"
end

module ActiveMcp
  JSON_RPC_VERSION = "2.0"
  PROTOCOL_VERSION = "2024-11-05"
end
