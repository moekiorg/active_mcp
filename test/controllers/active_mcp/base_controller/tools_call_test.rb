require "test_helper"

module ActiveMcp
  class BaseController
    class ToolsCallTest < ActionController::TestCase
      setup do
        @routes = ActiveMcp::Engine.routes
        @controller = ActiveMcp::BaseController.new
        @schema_class = Class.new(ActiveMcp::Schema::Base) do
          def tools
            [
              DummyTool.new,
              NoArgumentTool.new
            ]
          end
        end
      end

      test "should call tool successfully" do
        @controller.stub(:schema, @schema_class.new) do
          arguments = {name: "test-name", value: 42}

          post "index", params: {
            method: "tools/call",
            name: "test",
            arguments:
          }

          assert_response :success

          json = JSON.parse(response.body)
          assert json["result"]["content"][0]["text"].include?("Test tool result with name: test-name, value: 42")
        end
      end

      test "should call tool successfully when jsonrpc" do
        @controller.stub(:schema, @schema_class.new) do
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
      end

      test "should handle missing tool name" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {method: "tools/call", arguments: {}}
          assert_response :ok

          json = JSON.parse(response.body)
          assert_equal "Invalid params: missing tool name", json["result"]["content"][0]["text"]
        end
      end

      test "should handle tool not found" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {
            method: "tools/call",
            name: "nonexistent_tool",
            arguments: "{}"
          }

          assert_response :ok

          json = JSON.parse(response.body)
          assert_equal "Tool not found: nonexistent_tool", json["result"]["content"][0]["text"]
        end
      end

      test "should validate arguments" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {
            method: "tools/call",
            name: "test",
            arguments: {value: 123}
          }

          assert_response :ok

          json = JSON.parse(response.body)
          assert json["result"]["content"][0]["text"].include?("name")
        end
      end

      test "should pass authentication info to tool" do
        @controller.stub(:schema, @schema_class.new) do
          arguments = {name: "test-name", value: 42}

          @request.headers["Authorization"] = "Bearer test-token"
          post "index", params: {
            method: "tools/call",
            name: "test",
            arguments: arguments
          }

          json = JSON.parse(response.body)
          assert json["result"]["content"][0]["text"].include?("Authenticated tool result")
        end
      end

      test "should handle unknown method" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {method: "unknown_method"}
          assert_response :ok

          json = JSON.parse(response.body)
          assert_not_nil json["error"]
          assert_equal "Method not found", json["error"]
        end
      end
    end
  end
end
