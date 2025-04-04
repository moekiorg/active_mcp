require "test_helper"

module ActiveMcp
  class ToolManagerTest < ActiveSupport::TestCase
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
          "ToolManager executed with name: #{name}, value: #{value}"
        end
      end
      
      @test_tool_class.instance_variable_set(:@tool_name, "tool_manager_test_tool")
      
      Tool.registered_tools << @test_tool_class
    end
    
    test "should load registered tools" do
      @server.tool_manager.instance_variable_set(:@tools, [
        {
          name: "tool_manager_test_tool",
          description: "Tool manager test tool",
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
      
      tools = @server.tool_manager.tools
      assert_equal 1, tools.size
      assert_equal "tool_manager_test_tool", tools.first[:name]
      assert_equal "Tool manager test tool", tools.first[:description]
    end
    
    test "should find tool by name" do
      @server.tool_manager.instance_variable_set(:@tools, [
        {
          name: "tool_manager_test_tool",
          description: "Tool manager test tool"
        }
      ])
      
      tool_info = @server.tool_manager.tools.find { |t| t[:name] == "tool_manager_test_tool" }
      
      assert_not_nil tool_info
      assert_equal "Tool manager test tool", tool_info[:description]
    end
    
    test "should not find nonexistent tool" do
      @server.tool_manager.instance_variable_set(:@tools, [
        {
          name: "tool_manager_test_tool",
          description: "Tool manager test tool"
        }
      ])
      
      tool_info = @server.tool_manager.tools.find { |t| t[:name] == "nonexistent_tool" }
      
      assert_nil tool_info
    end
    
    test "should call tool with valid arguments" do
      @server.tool_manager.instance_variable_set(:@tools, [
        { name: "tool_manager_test_tool" }
      ])
      
      @server.tool_manager.stubs(:invoke_tool).with(
        "tool_manager_test_tool", 
        { name: "Test", value: 42 }
      ).returns({
        isError: false,
        content: [{ type: "text", text: "ToolManager executed with name: Test, value: 42" }]
      })
      
      result = @server.tool_manager.call_tool("tool_manager_test_tool", { name: "Test", value: 42 })
      
      assert_not_nil result
      assert_equal false, result[:isError]
      assert_equal "ToolManager executed with name: Test, value: 42", result[:content][0][:text]
    end
    
    test "should handle tool not found error" do
      @server.tool_manager.instance_variable_set(:@tools, [])
      
      result = @server.tool_manager.call_tool("nonexistent_tool", {})
      
      assert_not_nil result
      assert_equal true, result[:isError]
      assert_match(/Tool not found/, result[:content][0][:text])
    end
  end
end
