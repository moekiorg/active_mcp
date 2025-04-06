class AdminOnlyTool < ActiveMcp::Tool
  description "This tool is only accessible by admins"

  argument :command, :string, required: true, description: "Admin command to execute"

  def self.visible?(auth_info)
    return false unless auth_info
    return false unless auth_info[:type] == :bearer
    auth_info[:token] == "admin-token"
  end

  def call(command:, auth_info: nil)
    "Admin command executed: #{command}"
  end
end
