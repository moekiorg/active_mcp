class NoArgumentTool < ActiveMcp::Tool::Base
  def tool_name
    "no_argument"
  end

  def call(auth_info: nil)
  end
end
