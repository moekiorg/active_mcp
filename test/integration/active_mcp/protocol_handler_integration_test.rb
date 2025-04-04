require "test_helper"
require "mocha/minitest"

module ActiveMcp
  class ProtocolHandlerIntegrationTest < ActiveSupport::TestCase
    setup do
      @server = ActiveMcp::Server.new(
        name: "Test MCP Server",
        uri: "http://localhost:3000/mcp"
      )
      
      Tool.registered_tools = []
      
      @test_tool_class = Class.new(ActiveMcp::Tool) do
        description "Protocol handler test tool"
        
        property :name, :string, required: true, description: "Name parameter"
        
        def call(name:, **args)
          "ProtocolTool executed with name: #{name}"
        end
      end
      
      @test_tool_class.instance_variable_set(:@tool_name, "protocol_test_tool")
      
      Tool.registered_tools << @test_tool_class
    end
    
    test "should handle initialize request" do
      initialize_request = {
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 1,
        method: Method::INITIALIZE,
        params: {
          protocolVersion: ActiveMcp::PROTOCOL_VERSION
        }
      }
      
      result = @server.protocol_handler.process_message(initialize_request.to_json)
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 1, json_result["id"]
      assert_not_nil json_result["result"]
      assert_equal ActiveMcp::PROTOCOL_VERSION, json_result["result"]["protocolVersion"]
      assert_equal "Test MCP Server", json_result["result"]["serverInfo"]["name"]
    end
    
    test "should handle tools/list request" do
      initialize_request = {
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 1,
        method: Method::INITIALIZE,
        params: {
          protocolVersion: ActiveMcp::PROTOCOL_VERSION
        }
      }
      
      @server.protocol_handler.process_message(initialize_request.to_json)
      
      list_tools_request = {
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 2,
        method: Method::TOOLS_LIST
      }
      
      result = @server.protocol_handler.process_message(list_tools_request.to_json)
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 2, json_result["id"]
      assert_not_nil json_result["result"]
      
      assert_kind_of Hash, json_result["result"]
      assert_kind_of Array, json_result["result"]["tools"]
      
      tool_names = json_result["result"]["tools"].map { |tool| tool["name"] }
      assert_includes tool_names, "protocol_test_tool"
    end
    
    test "should handle tools/call request" do
      initialize_request = {
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 1,
        method: Method::INITIALIZE,
        params: {
          protocolVersion: ActiveMcp::PROTOCOL_VERSION
        }
      }
      
      @server.protocol_handler.process_message(initialize_request.to_json)
      
      test_tool = @test_tool_class.new
      
      @server.tool_manager.stubs(:find_tool).with("protocol_test_tool").returns(test_tool)
      
      @server.tool_manager.expects(:call_tool).with(
        "protocol_test_tool", 
        { name: "Test" }
      ).returns({
        content: [{ type: "text", text: "ProtocolTool executed with name: Test" }]
      })
      
      call_tool_request = {
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 3,
        method: Method::TOOLS_CALL,
        params: {
          name: "protocol_test_tool",
          arguments: { name: "Test" }
        }
      }
      
      result = @server.protocol_handler.process_message(call_tool_request.to_json)
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 3, json_result["id"]
      assert_not_nil json_result["result"]
      assert_equal "ProtocolTool executed with name: Test", json_result["result"]["content"][0]["text"]
    end
    
    test "should handle error for uninitialized server" do
      list_tools_request = {
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 1,
        method: Method::TOOLS_LIST
      }
      
      result = @server.protocol_handler.process_message(list_tools_request.to_json)
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 1, json_result["id"]
      assert_not_nil json_result["error"]
      assert_equal ErrorCode::NOT_INITIALIZED, json_result["error"]["code"]
    end
    
    test "should handle error for unsupported protocol version" do
      initialize_request = {
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 1,
        method: Method::INITIALIZE,
        params: {
          protocolVersion: "999.999" # Unsupported version
        }
      }
      
      result = @server.protocol_handler.process_message(initialize_request.to_json)
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 1, json_result["id"]
      assert_not_nil json_result["error"]
      assert_equal ErrorCode::INVALID_PARAMS, json_result["error"]["code"]
    end
    
    test "should handle error for invalid method" do
      initialize_request = {
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 1,
        method: Method::INITIALIZE,
        params: {
          protocolVersion: ActiveMcp::PROTOCOL_VERSION
        }
      }
      
      @server.protocol_handler.process_message(initialize_request.to_json)
      
      invalid_method_request = {
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 2,
        method: "invalid/method"
      }
      
      result = @server.protocol_handler.process_message(invalid_method_request.to_json)
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 2, json_result["id"]
      assert_not_nil json_result["error"]
      assert_equal ErrorCode::METHOD_NOT_FOUND, json_result["error"]["code"]
    end
  end
end
