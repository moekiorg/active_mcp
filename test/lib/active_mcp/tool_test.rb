require "test_helper"

module ActiveMcp
  class ToolTest < ActiveSupport::TestCase
    test "should register tool with name and description" do
      tool_class = Class.new(ActiveMcp::Tool) do
        description "Test tool description"
      end

      assert_equal "Test tool description", tool_class.desc
    end

    test "should define schema with properties" do
      tool_class = Class.new(ActiveMcp::Tool) do
        property :name, :string, required: true, description: "Name description"
        property :age, :integer, required: false
      end

      schema = tool_class.schema
      assert_equal "object", schema["type"]
      assert_equal "string", schema["properties"]["name"]["type"]
      assert_equal "Name description", schema["properties"]["name"]["description"]
      assert_equal "integer", schema["properties"]["age"]["type"]
      assert_includes schema["required"], "name"
      refute_includes schema["required"], "age"
    end

    test "should validate arguments against schema" do
      tool_class = Class.new(ActiveMcp::Tool) do
        description "validation_tool"

        property :name, :string, required: true
        property :age, :integer, required: false
      end

      tool = tool_class.new

      assert_equal true, tool.validate_arguments({name: "Test"})
      assert_equal true, tool.validate_arguments({name: "Test", age: 30})

      result = tool.validate_arguments({age: 30})
      assert result.is_a?(Hash)
      assert result[:error].present?
      assert_match(/name/, result[:error])
    end

    test "should add inherited tool classes to registered tools" do
      initial_count = ActiveMcp::Tool.registered_tools.count

      tool_class = Class.new(ActiveMcp::Tool)

      assert_equal initial_count + 1, ActiveMcp::Tool.registered_tools.count
      assert_includes ActiveMcp::Tool.registered_tools, tool_class
    end

    test "should raise NotImplementedError when call is not implemented" do
      tool_class = Class.new(ActiveMcp::Tool)

      tool = tool_class.new
      assert_raises NotImplementedError do
        tool.call(param: "value")
      end
    end

    test "should receive auth info in call method" do
      tool_class = Class.new(ActiveMcp::Tool) do
        property :param, :string, required: true

        def call(param:, auth_info: nil, **args)
          auth_type = auth_info&.dig(:type)
          auth_token = auth_info&.dig(:token)

          "Auth type: #{auth_type}, token: #{auth_token}, param: #{param}"
        end
      end

      tool = tool_class.new

      result = tool.call(param: "test")
      assert_equal "Auth type: , token: , param: test", result

      result = tool.call(
        param: "test",
        auth_info: {
          type: :bearer,
          token: "test-token",
          header: "Bearer test-token"
        }
      )
      assert_equal "Auth type: bearer, token: test-token, param: test", result

      result = tool.call(
        param: "test",
        auth_info: {
          type: :basic,
          token: "dXNlcjpwYXNz", # user:pass in base64
          header: "Basic dXNlcjpwYXNz"
        }
      )
      assert_equal "Auth type: basic, token: dXNlcjpwYXNz, param: test", result
    end
  end
end
