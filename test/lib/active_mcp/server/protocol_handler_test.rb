require "test_helper"

module ActiveMcp
  class Server
    class ProtocolHandlerTest < ActiveSupport::TestCase
      setup do
        @server = Server.new(
          name: "Test Server",
          version: "1.0.0",
          uri: "http://example.com"
        )
        @handler = ProtocolHandler.new(@server)
      end

      test "should initialize with correct attributes" do
        assert_equal false, @handler.initialized
      end

      test "should handle JSON parse error" do
        result = @handler.process_message("invalid json")
        json = JSON.parse(result)

        assert_equal "Invalid JSON format", json["error"]["message"]
        assert_equal ErrorCode::PARSE_ERROR, json["error"]["code"]
      end

      test "should handle initialize request" do
        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::INITIALIZE,
          params: {
            protocolVersion: PROTOCOL_VERSION
          }
        }.to_json)
        json = JSON.parse(result)

        assert_equal 1, json["id"]
        assert_equal "Test Server", json.dig("result", "serverInfo", "name")
        assert_equal "1.0.0", json.dig("result", "serverInfo", "version")
        assert_equal PROTOCOL_VERSION, json.dig("result", "protocolVersion")
        assert @handler.initialized
      end

      test "should reject invalid protocol version" do
        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::INITIALIZE,
          params: {
            protocolVersion: "invalid-version"
          }
        }.to_json)
        json = JSON.parse(result)

        assert_equal ErrorCode::INVALID_PARAMS, json["error"]["code"]
        assert_equal "Unsupported protocol version", json["error"]["message"]
        assert_equal [PROTOCOL_VERSION], json["error"]["data"]["supported"]
        assert_equal "invalid-version", json["error"]["data"]["requested"]
      end

      test "should reject double initialization" do
        # First initialization
        @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::INITIALIZE,
          params: {
            protocolVersion: PROTOCOL_VERSION
          }
        }.to_json)

        # Second initialization attempt
        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 2,
          method: Method::INITIALIZE,
          params: {
            protocolVersion: PROTOCOL_VERSION
          }
        }.to_json)
        json = JSON.parse(result)

        assert_equal ErrorCode::ALREADY_INITIALIZED, json["error"]["code"]
        assert_equal "Server already initialized", json["error"]["message"]
      end

      test "should handle ping request" do
        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::PING
        }.to_json)
        json = JSON.parse(result)

        assert_equal 1, json["id"]
        assert_equal({}, json["result"])
      end

      test "should handle unknown method" do
        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: "unknown_method"
        }.to_json)
        json = JSON.parse(result)

        assert_equal ErrorCode::METHOD_NOT_FOUND, json["error"]["code"]
        assert_match(/Unknown method/, json["error"]["message"])
      end

      test "should handle tools list request" do
        @server.stubs(:fetch).returns(result: {tools: [
          {name: "test-tool", description: "Test tool"}
        ]})

        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::TOOLS_LIST
        }.to_json)
        json = JSON.parse(result)

        assert_equal 1, json["id"]
        assert_equal "test-tool", json.dig("result", "tools", 0, "name")
      end

      test "should handle tool call request" do
        @server.stubs(:fetch).returns(
          result: {
            content: [{type: "text", text: "Tool result"}]
          }
        )

        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::TOOLS_CALL,
          params: {
            name: "test-tool",
            arguments: {arg: "value"}
          }
        }.to_json)
        json = JSON.parse(result)

        assert_equal 1, json["id"]
        assert_equal "Tool result", json.dig("result", "content", 0, "text")
      end

      test "should handle tool call error" do
        @server.stubs(:fetch).raises(StandardError.new("Tool error"))

        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::TOOLS_CALL,
          params: {
            name: "test-tool",
            arguments: {arg: "value"}
          }
        }.to_json)
        json = JSON.parse(result)

        assert_equal ErrorCode::INTERNAL_ERROR, json["error"]["code"]
        assert_equal "An internal error occurred", json["error"]["message"]
      end

      # Resource related tests
      test "should handle resources list request" do
        @server.stubs(:fetch).returns(result: {
          resources: [{uri: "test://resource1", type: "test"}]
        })

        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::RESOURCES_LIST
        }.to_json)
        json = JSON.parse(result)

        assert_equal 1, json["id"]
        assert_equal "test://resource1", json.dig("result", "resources", 0, "uri")
      end

      test "should handle resource templates list request" do
        @server.stubs(:fetch).returns(result: {resourceTemplates: [
          {uri: "template://test1", schema: {type: "object"}}
        ]})

        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::RESOURCES_TEMPLATES_LIST
        }.to_json)
        json = JSON.parse(result)

        assert_equal 1, json["id"]
        assert_equal "template://test1", json.dig("result", "resourceTemplates", 0, "uri")
      end

      test "should handle resource read request" do
        @server.stubs(:fetch).returns({result: {content: "Resource content"}})

        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::RESOURCES_READ,
          params: {
            uri: "test://resource1"
          }
        }.to_json)
        json = JSON.parse(result)

        assert_equal 1, json["id"]
        assert_equal "Resource content", json.dig("result", "content")
      end

      test "should handle resource read error" do
        @server.stubs(:fetch).raises(StandardError.new("Resource error"))

        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::RESOURCES_READ,
          params: {
            uri: "test://resource1"
          }
        }.to_json)
        json = JSON.parse(result)

        assert_equal ErrorCode::INTERNAL_ERROR, json["error"]["code"]
        assert_equal "An internal error occurred", json["error"]["message"]
      end

      # Prompts related tests
      test "should handle prompts list request" do
        @server.stubs(:fetch).returns(result: {prompts: [
          {name: "test-prompt", description: "Test prompt"}
        ]})

        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::PROMPTS_LIST
        }.to_json)
        json = JSON.parse(result)

        assert_equal 1, json["id"]
        assert_equal "test-prompt", json.dig("result", "prompts", 0, "name")
      end

      test "should handle get prompt request" do
        @server.stubs(:fetch).returns(
          messages: [{role: "user", content: "Test message"}]
        )

        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::PROMPTS_GET,
          params: {
            name: "test-prompt",
            arguments: {arg: "value"}
          }
        }.to_json)
        json = JSON.parse(result)

        assert_equal 1, json["id"]
        assert_equal "Test message", json.dig("result", "messages", 0, "content")
      end

      test "should handle get prompt error" do
        @server.stubs(:fetch).raises(StandardError.new("Prompt error"))

        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::PROMPTS_GET,
          params: {
            name: "test-prompt",
            arguments: {arg: "value"}
          }
        }.to_json)
        json = JSON.parse(result)

        assert_equal ErrorCode::INTERNAL_ERROR, json["error"]["code"]
        assert_equal "An internal error occurred", json["error"]["message"]
      end

      test "should handle completion request" do
        @server.stubs(:fetch).returns(result: {completion: {
          values: ["suggestion1", "suggestion2"],
          total: 2
        }})

        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::COMPLETION_COMPLETE,
          params: {
            ref: {type: "ref/resource", uri: "test://template"},
            argument: {name: "test", value: "value"}
          }
        }.to_json)
        json = JSON.parse(result)

        assert_equal 1, json["id"]
        assert_equal ["suggestion1", "suggestion2"], json.dig("result", "completion", "values")
        assert_equal 2, json.dig("result", "completion", "total")
      end

      test "should handle completion error" do
        @server.stubs(:fetch).raises(StandardError.new("Completion error"))

        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::COMPLETION_COMPLETE,
          params: {
            ref: {type: "ref/resource", uri: "test://template"},
            argument: {name: "test", value: "value"}
          }
        }.to_json)
        json = JSON.parse(result)

        assert_equal ErrorCode::INTERNAL_ERROR, json["error"]["code"]
        assert_equal "An internal error occurred", json["error"]["message"]
      end

      test "should handle initialized notification" do
        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          method: Method::INITIALIZED
        }.to_json)

        assert_nil result
        assert @handler.initialized
      end

      test "should handle internal error gracefully" do
        @server.stubs(:fetch).raises("Unexpected error")

        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::RESOURCES_LIST
        }.to_json)
        json = JSON.parse(result)

        assert_equal ErrorCode::INTERNAL_ERROR, json["error"]["code"]
        assert_equal "An internal error occurred", json["error"]["message"]
      end

      test "should handle prompts list error" do
        @server.stubs(:fetch).raises(StandardError.new("List error"))

        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::PROMPTS_LIST
        }.to_json)
        json = JSON.parse(result)

        assert_equal ErrorCode::INTERNAL_ERROR, json["error"]["code"]
        assert_equal "An internal error occurred", json["error"]["message"]
      end

      test "should handle resource templates list error" do
        @server.stubs(:fetch).raises(StandardError.new("Templates error"))

        result = @handler.process_message({
          jsonrpc: JSON_RPC_VERSION,
          id: 1,
          method: Method::RESOURCES_TEMPLATES_LIST
        }.to_json)
        json = JSON.parse(result)

        assert_equal ErrorCode::INTERNAL_ERROR, json["error"]["code"]
        assert_equal "An internal error occurred", json["error"]["message"]
      end

      test "should respond with error for invalid JSON-RPC format" do
        result = @handler.process_message({
          invalid: "format"
        }.to_json)
        json = JSON.parse(result)

        assert_equal ErrorCode::INVALID_REQUEST, json["error"]["code"]
        assert_equal "Invalid JSON-RPC format", json["error"]["message"]
      end
    end
  end
end
