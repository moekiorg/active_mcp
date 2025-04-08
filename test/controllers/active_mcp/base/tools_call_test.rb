require "test_helper"

module ActiveMcp
  module Controller
    class Base
      class ToolsCallTest < ActionController::TestCase
        setup do
          @routes = ActiveMcp::Engine.routes
          @controller = ActiveMcp::Controller::Base.new

          @test_tool_class = Class.new(ActiveMcp::Tool::Base) do
            argument :name, :string, required: true, description: "Name parameter"
            argument :value, :integer, required: false, description: "Value parameter"

            def tool_name
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
            def tool_name
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
            p json
            assert json["content"][0]["text"].include?("Test tool result with name: test-name, value: 42")
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
            assert_equal "Invalid params: missing tool name", json["content"][0]["text"]
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
            assert_equal "Tool not found: nonexistent_tool", json["content"][0]["text"]
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
            assert json["content"][0]["text"].include?("name")
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
            assert json["content"][0]["text"].include?("Authenticated tool result")
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
end
