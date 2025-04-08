# frozen_string_literal: true

module ActiveMcp
  module Method
    INITIALIZE = "initialize"
    INITIALIZED = "notifications/initialized"
    CANCELLED = "notifications/cancelled"
    PING = "ping"
    TOOLS_LIST = "tools/list"
    TOOLS_CALL = "tools/call"
    RESOURCES_LIST = "resources/list"
    RESOURCES_READ = "resources/read"
    RESOURCES_TEMPLATES_LIST = "resources/templates/list"
    COMPLETION_COMPLETE = "completion/complete"
    PROMPTS_LIST = "prompts/list"
    PROMPTS_GET = "prompts/get"
  end
end
