require "json"

module ActiveMcp
  class Server
    class ProtocolHandler
      attr_reader :initialized

      def initialize(server)
        @server = server
        @initialized = false
        @supported_protocol_versions = [PROTOCOL_VERSION]
      end

      def process_message(message)
        message = message.to_s.force_encoding("UTF-8")
        result = begin
          request = JSON.parse(message, symbolize_names: true)
          if !request[:jsonrpc] || !request[:method]
            error_response(nil, ErrorCode::INVALID_REQUEST, "Invalid JSON-RPC format")
          else
            handle_request(request)
          end
        rescue JSON::ParserError => e
          Server.log_error("JSON parse error", e)
          error_response(nil, ErrorCode::PARSE_ERROR, "Invalid JSON format")
        rescue => e
          Server.log_error("Internal error during message processing", e)
          error_response(nil, ErrorCode::INTERNAL_ERROR, "An internal error occurred")
        end

        json_result = JSON.generate(result).force_encoding("UTF-8") if result
        json_result
      end

      private

      def handle_request(request)
        case request[:method]
        when Method::INITIALIZE
          handle_initialize(request)
        when Method::INITIALIZED
          handle_initialized(request)
        when Method::PING
          handle_ping(request)
        when Method::RESOURCES_LIST
          handle_list_resources(request)
        when Method::RESOURCES_TEMPLATES_LIST
          handle_list_resource_templates(request)
        when Method::TOOLS_LIST
          handle_list_tools(request)
        when Method::TOOLS_CALL
          handle_call_tool(request)
        when Method::RESOURCES_READ
          handle_read_resource(request)
        when Method::COMPLETION_COMPLETE
          handle_complete(request)
        when Method::PROMPTS_LIST
          handle_list_prompts(request)
        when Method::PROMPTS_GET
          handle_get_prompt(request)
        else
          error_response(request[:id], ErrorCode::METHOD_NOT_FOUND, "Unknown method: #{request[:method]}")
        end
      rescue => e
        Server.log_error("Error #{name}", e)
        error_response(request[:id], ErrorCode::INTERNAL_ERROR, "An error occurred")
      end

      def handle_initialize(request)
        return error_response(request[:id], ErrorCode::ALREADY_INITIALIZED, "Server already initialized") if @initialized

        client_version = request.dig(:params, :protocolVersion)

        unless @supported_protocol_versions.include?(client_version)
          return error_response(
            request[:id],
            ErrorCode::INVALID_PARAMS,
            "Unsupported protocol version",
            {
              supported: @supported_protocol_versions,
              requested: client_version
            }
          )
        end

        response = {
          jsonrpc: JSON_RPC_VERSION,
          id: request[:id],
          result: {
            protocolVersion: PROTOCOL_VERSION,
            capabilities: {
              resources: {},
              tools: {},
              prompts: {}
            },
            serverInfo: {
              name: @server.name,
              version: @server.version
            }
          }
        }

        @initialized = true
        response
      end

      def handle_initialized(request)
        @initialized = true
        nil
      end

      def handle_ping(request)
        success_response(request[:id], {})
      end

      def handle_list_resources(request)
        success_response(
          request[:id],
          @server.fetch(
            params: {
              method: Method::RESOURCES_LIST,
              arguments: {}
            }
          )[:result]
        )
      end

      def handle_list_resource_templates(request)
        success_response(
          request[:id],
          @server.fetch(
            params: {
              method: Method::RESOURCES_TEMPLATES_LIST,
              arguments: {}
            }
          )[:result]
        )
      end

      def handle_list_tools(request)
        success_response(
          request[:id],
          @server.fetch(params: {method: Method::TOOLS_LIST, arguments: {}})[:result]
        )
      end

      def handle_call_tool(request)
        name = request.dig(:params, :name)
        arguments = request.dig(:params, :arguments) || {}
        result = @server.fetch(params: {method: Method::TOOLS_CALL, name:, arguments:})

        success_response(request[:id], result[:result])
      end

      def handle_read_resource(request)
        uri = request.dig(:params, :uri)
        result = @server.fetch(params: {method: Method::RESOURCES_READ, uri:, arguments: {}})

        success_response(request[:id], result[:result])
      end

      def handle_complete(request)
        result = @server.fetch(params: {method: Method::COMPLETION_COMPLETE, params: request[:params]})
        success_response(request[:id], result[:result])
      end

      def handle_list_prompts(request)
        result = @server.fetch(params: {method: Method::PROMPTS_LIST})
        success_response(request[:id], result[:result])
      end

      def handle_get_prompt(request)
        name = request.dig(:params, :name)
        arguments = request.dig(:params, :arguments)
        result = @server.fetch(params: {method: Method::PROMPTS_GET, params: {name:, arguments:}})

        success_response(request[:id], result[:result])
      end

      def success_response(id, result)
        {
          jsonrpc: JSON_RPC_VERSION,
          id: id,
          result:
        }
      end

      def error_response(id, code, message, data = nil)
        response = {
          jsonrpc: JSON_RPC_VERSION,
          id: id || 0,
          error: {
            code:,
            message:
          }
        }
        response[:error][:data] = data if data
        response
      end
    end
  end
end
