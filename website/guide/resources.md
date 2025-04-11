---
title: Resources
description: MCP Resources
---

# MCP Resources

Resources allow you to share data with AI models:

```ruby
class UserProfileResource < ActiveMcp::Resource::Base
  resource_tempalte_name "user-profile"
  uri_template "data://app/users/{id}"
  description "User profile data"
  mime_type "application/json"

  argument :id, complete: ->(value, context) do
    User.where("name LIKE ?", "%#{value}%").pluck(:name)
  end

  def initialize(id:)
    @user = User.find(id)
  end

  def resource_name
    @user.name
  end

  def uri
    "data://app/users/#{@user.id}"
  end

  def description
    "User profile for #{@user.name}"
  end

  def text
    {
      id: @user.id,
      name: @user.name,
      email: @user.email,
      role: @user.role,
      created_at: @user.created_at.iso8601
    }
  end
end
```

```ruby
class ApplicationSchema < ActiveMcp::Schema::Base
  resource UserProfileResource, items: User.all.map do |user|
    { id: user.id }
  end
end
```
