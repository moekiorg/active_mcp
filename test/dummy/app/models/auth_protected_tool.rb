class AuthProtectedTool < ActiveMcp::Tool
  description "Access a protected resource with authentication"

  property :resource_id, :string, required: true, description: "ID of the protected resource"
  property :action, :string, required: false, description: "Action to perform on the resource"

  def call(resource_id:, action: "read", auth_info: nil, **args)
    unless auth_info.present?
      raise "Authentication is required to access protected resources"
    end

    auth_type = auth_info[:type]
    token = auth_info[:token]

    user = authenticate_user(auth_type, token)
    unless user
      raise "Invalid authentication credentials"
    end

    resource = find_resource(resource_id)
    unless resource[:owner_id] == user[:id]
      raise "Access denied: You don't have permission to #{action} this resource"
    end

    result = perform_action(resource, action)

    {
      type: "text",
      content: "Successfully performed '#{action}' on resource #{resource_id}. Result: #{result}"
    }
  end

  private

  def authenticate_user(auth_type, token)
    if auth_type == :bearer && token == "valid-token"
      {id: 1, name: "Admin User"}
    elsif auth_type == :basic && token == "dXNlcjpwYXNz" # user:pass in base64
      {id: 2, name: "Regular User"}
    else
      nil
    end
  end

  def find_resource(resource_id)
    resources = {
      "1" => {id: "1", name: "Admin Document", content: "Confidential admin data", owner_id: 1},
      "2" => {id: "2", name: "User Document", content: "Regular user data", owner_id: 2},
      "3" => {id: "3", name: "Public Document", content: "Public data", owner_id: 3}
    }

    resources[resource_id] || {id: resource_id, name: "Not found", content: "Resource not found", owner_id: -1}
  end

  def perform_action(resource, action)
    case action
    when "read"
      "Content: #{resource[:content]}"
    when "update"
      "Resource updated successfully"
    when "delete"
      "Resource deleted successfully"
    else
      "Unknown action performed"
    end
  end
end
