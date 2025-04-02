class TestTool < ActiveMcp::Tool
  description "Test tool for ActiveMcp"

  property :name, :string, required: true, description: "Name parameter"
  property :value, :integer, required: false, description: "Value parameter"

  def call(name:, value: nil)
    "TestTool executed with name: #{name}, value: #{value}"
  end
end
