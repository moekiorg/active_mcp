require "test_helper"
require "mocha/minitest"

module ActiveMcp
  class ServerIntegrationTest < ActiveSupport::TestCase
    setup do
      @server = ActiveMcp::Server.new(
        name: "Test MCP Server",
        uri: "http://localhost:3000/mcp"
      )
      
      Tool.registered_tools = []
      
      @test_tool_class = Class.new(ActiveMcp::Tool) do
        description "Server integration test tool"
        
        property :name, :string, required: true, description: "Name parameter"
        property :value, :integer, required: false, description: "Value parameter"
        
        def call(name:, value: nil, **args)
          "ServerTool executed with name: #{name}, value: #{value}"
        end
      end
      
      @test_tool_class.instance_variable_set(:@tool_name, "server_test_tool")
      
      Tool.registered_tools << @test_tool_class
      
      @tool = @test_tool_class.new
    end
    
    test "should initialize server" do
      result = @server.protocol_handler.process_message({
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 1,
        method: Method::INITIALIZE,
        params: {
          protocolVersion: ActiveMcp::PROTOCOL_VERSION
        }
      }.to_json)
      
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 1, json_result["id"]
      assert_not_nil json_result["result"]
      assert_equal ActiveMcp::PROTOCOL_VERSION, json_result["result"]["protocolVersion"]
      assert_equal "Test MCP Server", json_result["result"]["serverInfo"]["name"]
    end
    
    test "should list available tools" do
      @server.protocol_handler.process_message({
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 1,
        method: Method::INITIALIZE,
        params: {
          protocolVersion: ActiveMcp::PROTOCOL_VERSION
        }
      }.to_json)
      
      result = @server.protocol_handler.process_message({
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 2,
        method: Method::TOOLS_LIST
      }.to_json)
      
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 2, json_result["id"]
      assert_not_nil json_result["result"]
      assert_not_nil json_result["result"]["tools"]
      
      tool_names = json_result["result"]["tools"].map { |tool| tool["name"] }
      assert_includes tool_names, "server_test_tool"
    end
    
    test "should call a tool successfully" do
      @server.protocol_handler.process_message({
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 1,
        method: Method::INITIALIZE,
        params: {
          protocolVersion: ActiveMcp::PROTOCOL_VERSION
        }
      }.to_json)
      
      result = @server.protocol_handler.process_message({
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 3,
        method: Method::TOOLS_CALL,
        params: {
          name: "server_test_tool",
          arguments: { name: "Test", value: 42 }
        }
      }.to_json)
      
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 3, json_result["id"]
      assert_not_nil json_result["result"]
      assert_match(/ServerTool executed with name: Test/, json_result["result"].to_s)
    end
    
    test "should handle validation errors" do
      @server.protocol_handler.process_message({
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 1,
        method: Method::INITIALIZE,
        params: {
          protocolVersion: ActiveMcp::PROTOCOL_VERSION
        }
      }.to_json)
      
      result = @server.protocol_handler.process_message({
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 4,
        method: Method::TOOLS_CALL,
        params: {
          name: "server_test_tool",
          arguments: { value: 42 }
        }
      }.to_json)
      
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 4, json_result["id"]
      assert_not_nil json_result["error"]
      assert_match(/name/, json_result["error"]["message"])
    end
    
    test "should handle tool not found error" do
      @server.protocol_handler.process_message({
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 1,
        method: Method::INITIALIZE,
        params: {
          protocolVersion: ActiveMcp::PROTOCOL_VERSION
        }
      }.to_json)
      
      result = @server.protocol_handler.process_message({
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 5,
        method: Method::TOOLS_CALL,
        params: {
          name: "nonexistent_tool",
          arguments: {}
        }
      }.to_json)
      
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 5, json_result["id"]
      assert_not_nil json_result["error"]
      assert_match(/Tool not found/, json_result["error"]["message"])
    end
    
    test "should handle error for uninitialized server" do
      result = @server.protocol_handler.process_message({
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 6,
        method: Method::TOOLS_LIST
      }.to_json)
      
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 6, json_result["id"]
      assert_not_nil json_result["error"]
      assert_equal ErrorCode::NOT_INITIALIZED, json_result["error"]["code"]
    end
    
    test "should handle error for unsupported protocol version" do
      result = @server.protocol_handler.process_message({
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 7,
        method: Method::INITIALIZE,
        params: {
          protocolVersion: "999.999" # Unsupported version
        }
      }.to_json)
      
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 7, json_result["id"]
      assert_not_nil json_result["error"]
      assert_equal ErrorCode::INVALID_PARAMS, json_result["error"]["code"]
    end
  end
end
