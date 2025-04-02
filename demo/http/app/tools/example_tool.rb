class ExampleTool < ActiveMcp::Tool
  description "Example"

  property :param1, :string, required: true, description: "First parameter description"
  property :param2, :string, required: false, description: "Second parameter description"

  def call(param1:, param2: nil, _auth_info: nil, **args)
    "Tool executed successfully with #{param1}"
  end
end
