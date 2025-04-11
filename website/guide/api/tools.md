# Tools

MCP Tools are the primary way to expose functionality to AI assistants. Tools can execute actions, process data, and return structured responses.

## Creating Tools

Create a tool by inheriting from `ActiveMcp::Tool::Base`:

```ruby
class SearchUsersTool < ActiveMcp::Tool::Base
  tool_name "search_users"
  description "Search users by name or email"

  argument :query, :string, required: true, description: "Search query"
  argument :limit, :integer, required: false, description: "Maximum results"

  def call(query:, limit: 10, context: {})
    users = User.where("name LIKE ? OR email LIKE ?", "%#{query}%", "%#{query}%")
      .limit(limit)

    [{
      type: "text",
      text: users.map(&:attributes).to_json
    }]
  end
end
```

## Tool Arguments

Define tool arguments using the `argument` method:

| Type       | Description                |
| ---------- | -------------------------- |
| `:string`  | Text values                |
| `:integer` | Whole numbers              |
| `:number`  | Decimal numbers            |
| `:boolean` | True/false values          |
| `:array`   | Lists of values            |
| `:object`  | Hash/dictionary structures |
| `:null`    | Null values                |

## Authorization

Control access to tools using the `visible?` class method:

```ruby
class AdminTool < ActiveMcp::Tool::Base
  def self.visible?(context:)
    return false unless context[:auth_info]
    return false unless context[:auth_info][:type] == :bearer

    token = context[:auth_info][:token]
    User.find_by_token(token)&.admin?
  end
end
```

## Response Format

Tools should return an array of content objects. Each content object can be:

```ruby
# Text content
[{
  type: "text",
  text: "Hello world"
}]

# Image content
[{
  type: "image",
  data: File.read("image.png"),
  mimeType: "image/png"
}]

# Audio content
[{
  type: "audio",
  data: File.read("audio.mp3"),
  mimeType: "audio/mpeg"
}]

# Resource reference
[{
  type: "resource",
  resource: {
    uri: "data://app/users/123",
    mimeType: "application/json",
    text: user.to_json
  }
}]
```

## Registration

Register tools in your schema:

```ruby
class MySchema < ActiveMcp::Schema::Base
  tool SearchUsersTool
  tool CreateUserTool
  tool UpdateUserTool
end
```

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
