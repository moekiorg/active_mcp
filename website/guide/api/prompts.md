# Prompts

MCP Prompts are pre-defined message templates that can be used to structure conversations with AI assistants.

## Creating Prompts

Create a prompt by inheriting from `ActiveMcp::Prompt::Base`:

```ruby
class WelcomePrompt < ActiveMcp::Prompt::Base
  prompt_name "welcome"
  description "Welcome message with user's name"

  argument :name, required: true, description: "User's name" do |value, context|
    User.where("name LIKE ?", "%#{value}%").pluck(:name)
  end

  def messages
    [{
      role: "user",
      content: {
        type: "text",
        text: "Hello! I'm #{@name}!"
      }
    }]
  end
end
```

## Prompt Arguments

Define arguments that can be used to customize the prompt:

```ruby
argument :name, required: true, description: "Description" do |value, context|
  # Optional: Provide autocompletion values
  ["suggestion1", "suggestion2"].filter { |s| s.include?(value) }
end
```

## Messages Format

Prompts should return an array of message objects. Each message has:

- `role`: The role of the message sender ("system", "user", "assistant")
- `content`: Content object that can contain text, images, audio, or resource references

Example response formats:

```ruby
def messages
  # Text message
  [{
    role: "user",
    content: {
      type: "text",
      text: "Hello world"
    }
  }]

  # Image message
  [{
    role: "user",
    content: {
      type: "image",
      data: File.read("welcome.png"),
      mimeType: "image/png"
    }
  }]

  # Resource reference
  [{
    role: "user",
    content: {
      type: "resource",
      resource: {
        uri: "data://app/welcome/123",
        mimeType: "text/plain",
        text: "Welcome message"
      }
    }
  }]
end
```

## Registration

Register prompts in your schema:

```ruby
class MySchema < ActiveMcp::Schema::Base
  prompt WelcomePrompt
  prompt HelpPrompt
  prompt ErrorPrompt
end
```

## Access Control

Control access to prompts using the `visible?` class method:

```ruby
class AdminPrompt < ActiveMcp::Prompt::Base
  def self.visible?(context:)
    return false unless context[:auth_info]
    return false unless context[:auth_info][:type] == :bearer

    token = context[:auth_info][:token]
    User.find_by_token(token)&.admin?
  end
end
```
