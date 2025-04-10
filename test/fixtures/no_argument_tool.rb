class NoArgumentTool < ActiveMcp::Tool::Base
  def tool_name
    "no_argument"
  end

  def call(context: {})
    []
  end
end
