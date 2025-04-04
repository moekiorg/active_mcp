require "test_helper"

module ActiveMcp
  class ToolRegistrationTest < ActiveSupport::TestCase
    setup do
      Tool.registered_tools = []
      
      @test_tool_class = Class.new(ActiveMcp::Tool) do
        description "Tool registration test tool"
        
        property :name, :string, required: true, description: "Name parameter"
        property :value, :integer, required: false, description: "Value parameter"
        
        def call(name:, value: nil, **args)
          "ToolRegistration executed with name: #{name}, value: #{value}"
        end
      end
      
      @test_tool_class.instance_variable_set(:@tool_name, "tool_registration_test_tool")
    end
    
    test "should register a tool" do
      initial_size = Tool.registered_tools.size
      
      Tool.registered_tools << @test_tool_class
      
      assert_equal initial_size + 1, Tool.registered_tools.size
      assert_includes Tool.registered_tools, @test_tool_class
    end
    
    test "should get tool schema" do
      Tool.registered_tools << @test_tool_class
      
      schema = @test_tool_class.schema
      
      assert_equal "object", schema["type"]
      assert_includes schema["required"], "name"
      assert_not_includes schema["required"], "value"
      assert_equal "string", schema["properties"]["name"]["type"]
      assert_equal "integer", schema["properties"]["value"]["type"]
    end
    
    test "should create tool instance" do
      Tool.registered_tools << @test_tool_class
      
      tool = @test_tool_class.new
      
      assert_instance_of @test_tool_class, tool
      assert_equal "Tool registration test tool", @test_tool_class.desc
    end
    
    test "should call tool with valid arguments" do
      Tool.registered_tools << @test_tool_class
      
      tool = @test_tool_class.new
      
      result = tool.call(name: "Test", value: 42)
      
      assert_equal "ToolRegistration executed with name: Test, value: 42", result
    end
    
    test "should validate tool arguments" do
      Tool.registered_tools << @test_tool_class
      
      tool = @test_tool_class.new
      
      assert_raises(ArgumentError) do
        tool.call(value: 42)
      end
      
      assert_nothing_raised do
        tool.call(name: "Test")
      end
    end
  end
end
