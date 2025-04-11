require "test_helper"

module ActiveMcp
  class ToolTest < ActiveSupport::TestCase
    test "should register tool with name and description" do
      tool_class = Class.new(ActiveMcp::Tool::Base) do
        def description
          "Test tool description"
        end
      end

      assert_equal "Test tool description", tool_class.new.description
    end

    test "should define schema with properties" do
      tool_class = Class.new(ActiveMcp::Tool::Base) do
        argument :name, :string, required: true, description: "Name description"
        argument :age, :integer, required: false
        argument :role, :string, required: false, visible: -> (context) { context[:role] == "admin" }
      end

      schema = tool_class.render_schema({ role: "editor" })
      assert_equal "object", schema["type"]
      assert_equal "string", schema["properties"]["name"]["type"]
      assert_equal "Name description", schema["properties"]["name"]["description"]
      assert_equal "integer", schema["properties"]["age"]["type"]
      assert_includes schema["required"], "name"
      refute_includes schema["required"], "age"
      assert_nil schema["properties"]["role"]
    end

    test "should validate arguments against schema" do
      tool_class = Class.new(ActiveMcp::Tool::Base) do
        argument :name, :string, required: true
        argument :age, :integer, required: false
        argument :role, :string, required: true, visible: ->(context) { context[:role] == "admin" }
      end

      tool = tool_class.new

      assert_equal true, tool.validate({name: "Test"}, {})
      assert_equal true, tool.validate({name: "Test", age: 30}, {})
      assert_not_equal true, tool.validate({name: "Test", age: 30}, {role: "admin"})

      result = tool.validate({age: 30}, {})
      assert result.is_a?(Hash)
      assert result[:error].present?
      assert_match(/name/, result[:error])
    end

    test "should raise NotImplementedError when call is not implemented" do
      tool_class = Class.new(ActiveMcp::Tool::Base) do
      end

      tool = tool_class.new
      assert_raises NotImplementedError do
        tool.call(param: "value")
      end
    end

    test "should receive auth info in call method" do
      tool_class = Class.new(ActiveMcp::Tool::Base) do
        argument :param, :string, required: true

        def call(param:, auth_info: nil, **_args)
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
