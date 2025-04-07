require "json"
require "English"
require_relative "server/method"
require_relative "server/error_codes"
require_relative "server/stdio_connection"
require_relative "server/fetcher"
require_relative "server/protocol_handler"

module ActiveMcp
  class Server
    attr_reader :name, :version, :uri, :protocol_handler, :fetcher

    def initialize(
      version: ActiveMcp::VERSION,
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

    def self.log_error(message, error)
      error_details = "#{message}: #{error.message}\n"
      error_details += error.backtrace.join("\n") if error.backtrace
      
      if defined?(Rails)
        Rails.logger.error(error_details)
      else
        $stderr.puts(error_details)
      end
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
