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
        
        # URIの検証
        unless @uri.is_a?(URI) || @uri.is_a?(String)
          log_error("Invalid URI type", StandardError.new("URI must be a String or URI object"))
          return {
            isError: true,
            content: [{type: "text", text: "Invalid URI configuration"}]
          }
        end
        
        begin
          uri = URI.parse(@uri.to_s)
          
          # 有効なスキームとホストの検証
          unless uri.scheme =~ /\Ahttps?\z/ && !uri.host.nil?
            log_error("Invalid URI", StandardError.new("URI must have a valid scheme and host"))
            return {
              isError: true,
              content: [{type: "text", text: "Invalid URI configuration"}]
            }
          end
          
          # 本番環境ではHTTPSを強制
          if defined?(Rails) && Rails.env.production? && uri.scheme != "https"
            return {
              isError: true,
              content: [{type: "text", text: "HTTPS is required in production environment"}]
            }
          end
        rescue URI::InvalidURIError => e
          log_error("Invalid URI format", e)
          return {
            isError: true,
            content: [{type: "text", text: "Invalid URI format"}]
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
        
        # URIの検証
        unless @uri.is_a?(URI) || @uri.is_a?(String)
          log_error("Invalid URI type", StandardError.new("URI must be a String or URI object"))
          return
        end
        
        begin
          uri = URI.parse(@uri.to_s)
          
          # 有効なスキームとホストの検証
          unless uri.scheme =~ /\Ahttps?\z/ && !uri.host.nil?
            log_error("Invalid URI", StandardError.new("URI must have a valid scheme and host"))
            return
          end
          
          # 本番環境ではHTTPSを強制
          if defined?(Rails) && Rails.env.production? && uri.scheme != "https"
            log_error("HTTPS is required in production environment", StandardError.new("Non-HTTPS URI in production"))
            return
          end
        rescue URI::InvalidURIError => e
          log_error("Invalid URI format", e)
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
