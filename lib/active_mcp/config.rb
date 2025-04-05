# frozen_string_literal: true

module ActiveMcp
  class Configuration
    attr_accessor :server_name, :server_version

    def initialize
      @server_name = "MCP Server"
      @server_version = "1.0.0"
    end
  end

  class << self
    def configure
      yield config
    end

    def config
      @config ||= Configuration.new
    end
  end
end
