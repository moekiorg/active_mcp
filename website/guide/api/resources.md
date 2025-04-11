# Resources

MCP Resources allow you to share data and files with AI assistants. Each resource has a URI, MIME type, and can return either text or binary data.

## Creating Resources

Create a resource by inheriting from `ActiveMcp::Resource::Base`:

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

  # def blob
    # File.read(@user.profile_picture.path)
  # end
end
```

## Registration

Register resources in your schema:

```ruby
class MySchema < ActiveMcp::Schema::Base
  resource UserResource, items: User.all.map { |user|
    { id: user.id }
  }
end
```

## Content Types

Resources can return two types of content:

1. **Text Content**: Use the `text` method to return structured data that will be JSON-serialized
2. **Binary Content**: Use the `blob` method to return raw binary data

## Access Control

Control access to resources by implementing the `visible?` class method:

```ruby
def self.visible?(context:)
  return false unless context[:auth_info]
  return false unless context[:auth_info][:type] == :bearer

  # Your custom authorization logic
  token = context[:auth_info][:token]
  User.exists?(api_token: token)
end
```

And `visible?` instance method to check if the resource is visible to the user:

```ruby
def visible?(context:)
  return false unless context[:auth_info]
  return false unless context[:auth_info][:type] == :bearer

  # Your custom authorization logic
  token = context[:auth_info][:token]
  User.exists?(api_token: token)
end
```
