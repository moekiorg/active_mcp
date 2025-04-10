class DummyTool < ActiveMcp::Tool::Base
  tool_name "dummy"

  description "Test tool for controller testing"

  argument :name, :string, required: true, description: "Name parameter"

  argument :value, :integer, required: false, description: "Value parameter"

  def call(name:, value: nil, context: {})
    context ||= {}
    if context[:auth_info] && context[:auth_info][:type] == :bearer
      "Authenticated tool result with name: #{name}, value: #{value}"
    else
      "Test tool result with name: #{name}, value: #{value}"
    end
  end
end
