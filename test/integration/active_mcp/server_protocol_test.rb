require "test_helper"
require "mocha/minitest"

module ActiveMcp
  class ServerProtocolTest < ActiveSupport::TestCase
    setup do
      @server = ActiveMcp::Server.new(
        name: "Test MCP Server",
        uri: "http://localhost:3000/mcp"
      )
      
      Tool.registered_tools = []
      
      @test_tool_class = Class.new(ActiveMcp::Tool) do
        description "Server protocol test tool"
        
        property :name, :string, required: true, description: "Name parameter"
        property :value, :integer, required: false, description: "Value parameter"
        
        def call(name:, value: nil, **args)
          "ServerProtocolTool executed with name: #{name}, value: #{value}"
        end
      end
      
      @test_tool_class.instance_variable_set(:@tool_name, "server_protocol_tool")
      
      Tool.registered_tools << @test_tool_class
      
      @server.tool_manager.stubs(:tools).returns([
        {
          name: "server_protocol_tool",
          description: "Server protocol test tool",
          inputSchema: {
            type: "object",
            properties: {
              name: {
                type: "string",
                description: "Name parameter"
              },
              value: {
                type: "integer",
                description: "Value parameter"
              }
            },
            required: ["name"]
          }
        }
      ])
      
      @server.tool_manager.stubs(:call_tool).with("server_protocol_tool", anything).returns(
        { content: [{ type: "text", text: "ServerProtocolTool executed with name: Test, value: 42" }] }
      )
      
      @server.protocol_handler.stubs(:handle_tools_call).with(has_entry(:params => has_entries(
        name: "server_protocol_tool", 
        arguments: has_entry(:value => 42)
      ))).returns({
        error: {
          code: ErrorCode::INVALID_PARAMS,
          message: "Missing required parameter: name"
        }
      })
      
      @server.protocol_handler.stubs(:handle_tools_call).with(has_entry(:params => has_entries(
        name: "nonexistent_tool"
      ))).returns({
        error: {
          code: ErrorCode::INVALID_PARAMS,
          message: "Tool not found: nonexistent_tool"
        }
      })
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
      assert_not_nil json_result["result"]["tools"]
      
      tool_names = json_result["result"]["tools"].map { |tool| tool["name"] }
      assert_includes tool_names, "server_protocol_tool"
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
      
      call_tool_request = {
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 3,
        method: Method::TOOLS_CALL,
        params: {
          name: "server_protocol_tool",
          arguments: { name: "Test", value: 42 }
        }
      }
      
      result = @server.protocol_handler.process_message(call_tool_request.to_json)
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 3, json_result["id"]
      assert_not_nil json_result["result"]
      assert_equal "ServerProtocolTool executed with name: Test, value: 42", json_result["result"]["content"][0]["text"]
    end
    
    test "should handle validation errors" do
      initialize_request = {
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 1,
        method: Method::INITIALIZE,
        params: {
          protocolVersion: ActiveMcp::PROTOCOL_VERSION
        }
      }
      
      @server.protocol_handler.process_message(initialize_request.to_json)
      
      call_tool_request = {
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 4,
        method: Method::TOOLS_CALL,
        params: {
          name: "server_protocol_tool",
          arguments: { value: 42 }
        }
      }
      
      result = @server.protocol_handler.process_message(call_tool_request.to_json)
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 4, json_result["id"]
      assert_not_nil json_result["error"]
      assert_match(/Missing required parameter: name/, json_result["error"]["message"].to_s)
    end
    
    test "should handle tool not found error" do
      initialize_request = {
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 1,
        method: Method::INITIALIZE,
        params: {
          protocolVersion: ActiveMcp::PROTOCOL_VERSION
        }
      }
      
      @server.protocol_handler.process_message(initialize_request.to_json)
      
      call_tool_request = {
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 5,
        method: Method::TOOLS_CALL,
        params: {
          name: "nonexistent_tool",
          arguments: {}
        }
      }
      
      result = @server.protocol_handler.process_message(call_tool_request.to_json)
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 5, json_result["id"]
      assert_not_nil json_result["error"]
      assert_match(/Tool not found: nonexistent_tool/, json_result["error"]["message"].to_s)
    end
    
    test "should handle error for uninitialized server" do
      list_tools_request = {
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 6,
        method: Method::TOOLS_LIST
      }
      
      result = @server.protocol_handler.process_message(list_tools_request.to_json)
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 6, json_result["id"]
      assert_not_nil json_result["error"]
      assert_equal ErrorCode::NOT_INITIALIZED, json_result["error"]["code"]
    end
    
    test "should handle error for unsupported protocol version" do
      initialize_request = {
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 7,
        method: Method::INITIALIZE,
        params: {
          protocolVersion: "999.999" # Unsupported version
        }
      }
      
      result = @server.protocol_handler.process_message(initialize_request.to_json)
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 7, json_result["id"]
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
        id: 8,
        method: "invalid/method"
      }
      
      result = @server.protocol_handler.process_message(invalid_method_request.to_json)
      json_result = JSON.parse(result)
      
      assert_equal ActiveMcp::JSON_RPC_VERSION, json_result["jsonrpc"]
      assert_equal 8, json_result["id"]
      assert_not_nil json_result["error"]
      assert_equal ErrorCode::METHOD_NOT_FOUND, json_result["error"]["code"]
    end
  end
end
