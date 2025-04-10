require "test_helper"

module ActiveMcp
  class BaseController
    class ToolsListTest < ActionController::TestCase
      setup do
        @routes = ActiveMcp::Engine.routes
        @controller = ActiveMcp::BaseController.new
        @schema_class = Class.new(ActiveMcp::Schema::Base) do
          tool DummyTool
          tool NoArgumentTool
        end
      end

      test "should return tools list" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {method: "tools/list"}

          assert_response :success

          json = JSON.parse(response.body)
          assert_not_nil json["result"]

          tools = json["result"]["tools"]
          test_tool = tools.find { |t| t["name"] == "dummy" }
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
          test_tool = tools.find { |t| t["name"] == "dummy" }
          assert_not_nil test_tool
          assert_equal "Test tool for controller testing", test_tool["description"]
          assert_not_nil test_tool["inputSchema"]
        end
      end
    end
  end
end
