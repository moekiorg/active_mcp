---
title: Tools
description: MCP Tools
---

# MCP Tools

Tools are the primary way to expose functionality to AI models:

```ruby
class SearchUsersTool < ActiveMcp::Tool::Base
  tool_name "search_users"
  description "Search users by various criteria"

  # Define the input schema
  argument :email, :string, required: false, description: "Email to search for"
  argument :name, :string, required: false, description: "Name to search for"
  argument :limit, :integer, required: false, description: "Maximum number of results"
  argument :role, :string, required: false, visible: ->(context) { context[:role] == "admin" }

  def call(email: nil, name: nil, limit: 10, context: {})
    criteria = {}
    criteria[:email] = email if email.present?
    criteria[:name] = name if name.present?

    users = User.where(criteria).limit(limit)

    [{
      type: "text",
      text: {
        users: users.map { |user| user.attributes.slice("id", "name", "email") },
        total: users.count
      }.to_json
    }]
  end
end
```
