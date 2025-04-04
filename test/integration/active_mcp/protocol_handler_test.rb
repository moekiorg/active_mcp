require "test_helper"

module ActiveMcp
  class ProtocolHandlerTest < ActiveSupport::TestCase
    setup do
      @server = ActiveMcp::Server.new(
        name: "Test MCP Server",
        uri: "http://localhost:3000/mcp"
      )
      
      Tool.registered_tools = []
      
      @test_tool_class = Class.new(ActiveMcp::Tool) do
        description "Protocol handler test tool"
        
        property :name, :string, required: true, description: "Name parameter"
        property :value, :integer, required: false, description: "Value parameter"
        
        def call(name:, value: nil, **args)
          "ProtocolTool executed with name: #{name}, value: #{value}"
        end
      end
      
      @test_tool_class.instance_variable_set(:@tool_name, "protocol_test_tool")
      
      Tool.registered_tools << @test_tool_class
    end
    
    test "should initialize server" do
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
