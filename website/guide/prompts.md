---
title: Prompts
description: MCP Prompts
---

# MCP Prompts

Prompts help you define reusable message templates:

```ruby
class WelcomePrompt < ActiveMcp::Prompt::Base
  prompt_name "welcome"
  description "Generate a personalized welcome message"

  argument :user_name, required: true, description: "User's name"

  def messages(user_name:)
    [
      ActiveMcp::Message::Text.new(
        role: "system",
        text: "You are a friendly assistant welcoming users to our platform."
      ),
      ActiveMcp::Message::Text.new(
        role: "user",
        text: "Generate a warm welcome message for #{user_name}"
      )
    ]
  end
end
```

And register prompt to schema:

```ruby
class ApplicationSchema < ActiveMcp::Schema::Base
  prompt WelcomePrompt
end
```
