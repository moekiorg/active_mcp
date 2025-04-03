require "json"

module ActiveMcp
  class Server
    class ToolManager
      attr_reader :tools

      def initialize(uri: nil, auth: nil)
        @tools = {}
        @uri = uri

        if auth
          @auth_header = "#{auth[:type] == :bearer ? "Bearer" : "Basic"} #{auth[:token]}"
        end
      end

      def call_tool(name, arguments = {})
        tool_info = @tools.find { _1[:name] == name }

        unless tool_info
          return {
            isError: true,
            content: [{type: "text", text: "Tool not found: #{name}"}]
          }
        end

        invoke_tool(name, arguments)
      end

      def load_registered_tools
        fetch_tools
      end

      private

      def invoke_tool(name, arguments)
        require "net/http"
        uri = URI.parse(@uri.to_s)
        
        # 本番環境ではHTTPSを強制
        if defined?(Rails) && Rails.env.production? && uri.scheme != "https"
          return {
            isError: true,
            content: [{type: "text", text: "HTTPS is required in production environment"}]
          }
        end
        
        request = Net::HTTP::Post.new(uri)
        request.body = JSON.generate({
          method: "tools/call",
          name:,
          arguments: arguments.to_json
        })
        request["Content-Type"] = "application/json"
        request["Authorization"] = @auth_header

        begin
          response = Net::HTTP.start(uri.hostname, uri.port) do |http|
            http.request(request)
          end

          if response.code == "200"
            body = JSON.parse(response.body, symbolize_names: true)
            if body[:error]
              {
                isError: true,
                content: [{type: "text", text: body[:error]}]
              }
            else
              format_result(body[:result])
            end
          else
            {
              isError: true,
              content: [{type: "text", text: "HTTP Error: #{response.code}"}]
            }
          end
        rescue => e
          # ログに詳細を記録
          log_error("Error calling tool", e)
          {
            isError: true,
            content: [{type: "text", text: "Error calling tool"}]
          }
        end
      end

      def fetch_tools
        return unless @uri

        require "net/http"
        uri = URI.parse(@uri.to_s)
        
        # 本番環境ではHTTPSを強制
        if defined?(Rails) && Rails.env.production? && uri.scheme != "https"
          Rails.logger.error("HTTPS is required in production environment")
          return
        end
        
        request = Net::HTTP::Post.new(uri)
        request.body = JSON.generate({
          method: "tools/list",
          arguments: "{}"
        })
        request["Content-Type"] = "application/json"
        request["Authorization"] = @auth_header

        begin
          response = Net::HTTP.start(uri.hostname, uri.port) do |http|
            http.request(request)
          end

          result = JSON.parse(response.body, symbolize_names: true)
          @tools = result[:result]
        rescue => e
          log_error("Error fetching tools", e)
          @tools = []
        end
      end

      def format_result(result)
        case result
        when String
          {content: [{type: "text", text: result}]}
        when Hash
          {content: [{type: "text", text: result.to_json}]}
        else
          {content: [{type: "text", text: result.to_s}]}
        end
      end
      
      def log_error(message, error)
        error_details = "#{message}: #{error.message}\n"
        error_details += error.backtrace.join("\n") if error.backtrace
        
        if defined?(Rails)
          Rails.logger.error(error_details)
        else
          # Fallback to standard error output if Rails is not available
          $stderr.puts(error_details)
        end
      end
    end
  end
end
