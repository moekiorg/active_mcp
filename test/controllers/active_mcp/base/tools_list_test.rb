require "test_helper"

module ActiveMcp
  class BaseControllerText < ActionController::TestCase
    setup do
      @routes = ActiveMcp::Engine.routes
      @controller = ActiveMcp::Controller::Base.new

      @test_tool_class = Class.new(ActiveMcp::Tool::Base) do
        argument :name, :string, required: true, description: "Name parameter"
        argument :value, :integer, required: false, description: "Value parameter"

        def name
          "test"
        end

        def description
          "Test tool for controller testing"
        end

        def call(name:, value: nil, context: {})
          context ||= {}
          if context[:auth_info] && context[:auth_info][:type] == :bearer
            "Authenticated tool result with name: #{name}, value: #{value}"
          else
            "Test tool result with name: #{name}, value: #{value}"
          end
        end
      end

      @no_argument_tool = Class.new(ActiveMcp::Tool::Base) do
        def name
          "no_argument"
        end

        def call(auth_info: nil)
        end
      end

      Object.const_set(:TestTool, @test_tool_class)
      Object.const_set(:NoArgumentTool, @no_argument_tool)

      @schema_class = Class.new(ActiveMcp::Schema::Base) do
        tool TestTool.new
        tool NoArgumentTool.new
      end
    end

    test "should return tools list" do
      @controller.stub(:schema, @schema_class.new) do
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
    end

    test "should return tools list when jsonrpc" do
      @controller.stub(:schema, @schema_class.new) do
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
end
