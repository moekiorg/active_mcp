class ExampleTool < ActiveMcp::Tool::Base
  argument :name, :string, required: true, description: "Name parameter"
  argument :value, :integer, required: false, description: "Value parameter"

  def tool_name
    "test"
  end

  def description
    "Test tool for controller testing"
  end

  def call(name:, value: nil, auth_info: nil)
    if auth_info && auth_info[:type] == :bearer
      "Authenticated tool result with name: #{name}, value: #{value}"
    else
      "Test tool result with name: #{name}, value: #{value}"
    end
  end
end
