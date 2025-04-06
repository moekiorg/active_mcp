require "test_helper"

module ActiveMcp
  class BaseControllerText < ActionController::TestCase
    setup do
      @routes = ActiveMcp::Engine.routes
      @controller = ActiveMcp::BaseController.new

      ActiveMcp::Tool.registered_tools = []

      @test_tool_class = Class.new(ActiveMcp::Tool) do
        description "Test tool for controller testing"

        property :name, :string, required: true, description: "Name parameter"
        property :value, :integer, required: false, description: "Value parameter"

        def call(name:, value: nil, auth_info: nil)
          if auth_info && auth_info[:type] == :bearer
            "Authenticated tool result with name: #{name}, value: #{value}"
          else
            "Test tool result with name: #{name}, value: #{value}"
          end
        end
      end

      Object.const_set(:TestTool, @test_tool_class)

      ActiveMcp::Tool.registered_tools << @test_tool_class unless ActiveMcp::Tool.registered_tools.include?(@test_tool_class)
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

    test "should call tool successfully" do
      arguments = {name: "test-name", value: 42}

      post "index", params: {
        method: "tools/call",
        name: "test",
        arguments:
      }

      assert_response :success

      json = JSON.parse(response.body)
      assert json["result"].include?("Test tool result with name: test-name, value: 42")
    end

    test "should call tool successfully when jsonrpc" do
      arguments = {name: "test-name", value: 42}

      post "index", params: {
        jsonrpc: "2.0",
        method: "tools/call",
        params: {
          name: "test",
          arguments:
        }
      }

      assert_response :success

      json = JSON.parse(response.body)
      assert json["result"]["content"][0]["text"].include?("Test tool result with name: test-name, value: 42")
    end

    test "should handle missing tool name" do
      post "index", params: {method: "tools/call", arguments: {}}
      assert_response :ok

      json = JSON.parse(response.body)
      assert_equal "Invalid params: missing tool name", json["result"]
    end

    test "should handle tool not found" do
      post "index", params: {
        method: "tools/call",
        name: "nonexistent_tool",
        arguments: "{}"
      }

      assert_response :ok

      json = JSON.parse(response.body)
      assert_equal "Tool not found: nonexistent_tool", json["result"]
    end

    test "should validate arguments" do
      post "index", params: {
        method: "tools/call",
        name: "test",
        arguments: {value: 123}
      }

      assert_response :ok

      json = JSON.parse(response.body)
      assert json["result"].include?("name")
    end

    test "should pass authentication info to tool" do
      arguments = {name: "test-name", value: 42}

      @request.headers["Authorization"] = "Bearer test-token"
      post "index", params: {
        method: "tools/call",
        name: "test",
        arguments: arguments
      }

      json = JSON.parse(response.body)
      assert json["result"].include?("Authenticated tool result")
    end

    test "should handle unknown method" do
      post "index", params: {method: "unknown_method"}
      assert_response :not_found

      json = JSON.parse(response.body)
      assert_not_nil json["error"]
      assert_equal "Method not found", json["error"]
    end
  end
end
