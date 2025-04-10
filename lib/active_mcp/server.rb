require "json"
require "English"
require_relative "server/method"
require_relative "server/error_code"
require_relative "server/stdio_connection"
require_relative "server/fetcher"
require_relative "server/protocol_handler"

module ActiveMcp
  class Server
    class Logger
      attr_reader :messages

      def initialize
        @messages = []
      end

      def log(message, error = nil)
        @messages << {message: message, error: error}
        if defined?(Rails)
          Rails.logger.error("#{message}: #{error&.message}")
        else
          warn("#{message}: #{error&.message}")
        end
      end
    end

    class << self
      def logger
        @logger ||= Logger.new
      end

      def log_error(message, error)
        logger.log(message, error)
      end
    end

    attr_reader :name, :version, :uri, :protocol_handler, :fetcher

    def initialize(
      version: "1.0.0",
      name: "ActiveMcp",
      uri: nil,
      auth: nil
    )
      @name = name
      @version = version
      @uri = uri
      @fetcher = Fetcher.new(base_uri: uri, auth:)
      @protocol_handler = ProtocolHandler.new(self)
    end

    def fetch(params:)
      @fetcher.call(params:)
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
