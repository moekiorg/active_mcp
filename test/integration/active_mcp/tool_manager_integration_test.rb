require "test_helper"

module ActiveMcp
  class ToolManagerIntegrationTest < ActiveSupport::TestCase
    setup do
      @server = ActiveMcp::Server.new(
        name: "Test MCP Server",
        uri: "http://localhost:3000/mcp"
      )
      
      Tool.registered_tools = []
      
      @test_tool_class = Class.new(ActiveMcp::Tool) do
        description "Tool manager test tool"
        
        property :name, :string, required: true, description: "Name parameter"
        property :value, :integer, required: false, description: "Value parameter"
        
        def call(name:, value: nil, **args)
          "ToolManager test tool executed with name: #{name}, value: #{value}"
        end
      end
      
      @test_tool_class.instance_variable_set(:@tool_name, "tool_manager_test_tool")
      
      Tool.registered_tools << @test_tool_class
    end
    
    test "should register and find tools" do
      @server.protocol_handler.process_message({
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 1,
        method: Method::INITIALIZE,
        params: {
          protocolVersion: ActiveMcp::PROTOCOL_VERSION
        }
      }.to_json)
      
      tools = @server.tool_manager.tools
      assert_equal 1, tools.length
      
      tool = tools.first
      assert_equal "tool_manager_test_tool", tool[:name]
      assert_equal "Tool manager test tool", tool[:description]
      assert_not_nil tool[:inputSchema]
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
      
      result = @server.tool_manager.call_tool("tool_manager_test_tool", { name: "Test", value: 42 })
      
      assert_not_nil result
      assert_equal "ToolManager test tool executed with name: Test, value: 42", result
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
      
      assert_raises(RuntimeError) do
        @server.tool_manager.call_tool("tool_manager_test_tool", { value: 42 })
      end
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
      
      assert_raises(RuntimeError) do
        @server.tool_manager.call_tool("nonexistent_tool", {})
      end
    end
  end
end
