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
          {
            isError: true,
            content: [{type: "text", text: "Error calling tool: #{e.message}"}]
          }
        end
      end

      def fetch_tools
        return unless @uri

        require "net/http"
        uri = URI.parse(@uri.to_s)
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
        rescue
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
    end
  end
end
