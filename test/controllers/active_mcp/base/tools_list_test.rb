require "test_helper"

module ActiveMcp
  class BaseControllerText < ActionController::TestCase
    setup do
      @routes = ActiveMcp::Engine.routes
      @controller = ActiveMcp::BaseController.new

      ActiveMcp::Tool.registered_tools = []

      @test_tool_class = Class.new(ActiveMcp::Tool) do
        description "Test tool for controller testing"

        argument :name, :string, required: true, description: "Name parameter"
        argument :value, :integer, required: false, description: "Value parameter"

        def call(name:, value: nil, auth_info: nil)
          if auth_info && auth_info[:type] == :bearer
            "Authenticated tool result with name: #{name}, value: #{value}"
          else
            "Test tool result with name: #{name}, value: #{value}"
          end
        end
      end

      @no_argument_tool = Class.new(ActiveMcp::Tool) do
        def call(auth_info: nil)
        end
      end

      Object.const_set(:TestTool, @test_tool_class)
      Object.const_set(:NoArgumentTool, @no_argument_tool)

      ActiveMcp::Tool.registered_tools << @test_tool_class unless ActiveMcp::Tool.registered_tools.include?(@test_tool_class)
      ActiveMcp::Tool.registered_tools << @no_argument_tool unless ActiveMcp::Tool.registered_tools.include?(@no_argument_tool)
    end

    test "should return tools list" do
      post "index", params: {method: "tools/list"}

      assert_response :success

      json = JSON.parse(response.body)
      assert_not_nil json["result"]

      tools = json["result"]
      test_tool = tools.find { |t| t["name"] == "test" }
      assert_not_nil test_tool
      assert_equal "Test tool for controller testing", test_tool["description"]
      assert_not_nil test_tool["inputSchema"]
    end

    test "should return tools list when jsonrpc" do
      post "index", params: {jsonrpc: "2.0", method: "tools/list"}

      assert_response :success

      json = JSON.parse(response.body)
      assert_not_nil json["result"]

      tools = json["result"]["tools"]
      test_tool = tools.find { |t| t["name"] == "test" }
      assert_not_nil test_tool
      assert_equal "Test tool for controller testing", test_tool["description"]
      assert_not_nil test_tool["inputSchema"]
    end
  end
end
