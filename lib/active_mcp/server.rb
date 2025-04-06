require "json"
require "English"
require_relative "server/method"
require_relative "server/error_codes"
require_relative "server/stdio_connection"
require_relative "server/resource_manager"
require_relative "server/tool_manager"
require_relative "server/protocol_handler"

module ActiveMcp
  class Server
    attr_reader :name, :version, :uri, :tool_manager, :protocol_handler, :resource_manager

    def initialize(
      version: ActiveMcp::VERSION,
      name: "ActiveMcp",
      uri: nil,
      auth: nil
    )
      @name = name
      @version = version
      @uri = uri
      @resource_manager = ResourceManager.new(uri:, auth:)
      @tool_manager = ToolManager.new(uri: uri, auth:)
      @protocol_handler = ProtocolHandler.new(self)
      @tool_manager.load_registered_tools
      @resource_manager.load_registered_resources
    end

    def start
      serve_stdio
    end

    def serve_stdio
      serve(StdioConnection.new)
    end

    def serve(connection)
      loop do
        message = connection.read_next_message
        break if message.nil?

        response = @protocol_handler.process_message(message)
        next if response.nil?

        connection.send_message(response)
      end
    end

    def initialized
      @protocol_handler.initialized
    end

    def tools
      @tool_manager.tools
    end
  end
end
