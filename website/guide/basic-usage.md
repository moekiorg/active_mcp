---
title: Basic Usage
description: How to use Active MCP in your Rails application
---

# Basic Usage

This guide shows you how to use Active MCP in your Rails application after installation and configuration.

## Setting Up Your Schema

The schema is the central place to define your MCP tools, resources, and prompts:

```ruby
class ApplicationSchema < ActiveMcp::Schema::Base
  # Register tools
  tool SearchUsersTool
  tool CreateNoteTool

  # Register resources with their items
  resource UserProfileResource, items: User.all.map do |user|
    { id: user.id }
  end
  resource ProductResource, items: Product.all.map do |product|
    { id: product.id }
  end

  # Register prompts
  prompt WelcomePrompt
  prompt ProductDescriptionPrompt
end
```

## Creating MCP Tools

Tools are the primary way to expose functionality to AI models:

```ruby
class SearchUsersTool < ActiveMcp::Tool::Base
  tool_name "search_users"
  description "Search users by various criteria"

  # Define the input schema
  argument :email, :string, required: false, description: "Email to search for"
  argument :name, :string, required: false, description: "Name to search for"
  argument :limit, :integer, required: false, description: "Maximum number of results"

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

## Creating Resources

Resources allow you to share data with AI models:

```ruby
class UserProfileResource < ActiveMcp::Resource::Base
  resource_tempalte_name "user-profile"
  uri_template "data://app/users/{id}"
  description "User profile data"
  mime_type "application/json"

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

## Creating Prompts

Prompts help you define reusable message templates:

```ruby
class WelcomePrompt < ActiveMcp::Prompt::Base
  prompt_name "welcome"
  description "Generate a personalized welcome message"

  argument :user_name,
    required: true,
    description: "User's name",
    complete: ->(value, context) do
      User.all.pluck(:name).filter { _1.match(value) }
    end

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

Create controller ans set up routing:

```ruby
class MyMcpController < ActiveMcp::BaseController

  private

  def schema
    ApplicationSchema.new(context:)
  end
end
```

```ruby
Rails.application.routes.draw do
  post "/mcp", to: "my_mcp#index"

  # Your other routes
end
```

## 🔌 MCP Connection Methods

Active MCP supports two connection methods:

### 1. Direct HTTP Connection

Set your MCP client to connect directly to your Rails application:

```
https://your-app.example.com/mcp
```

### 2. Standalone MCP Server

Start a dedicated MCP server that communicates with your Rails app:

```ruby
# script/mcp_server.rb
server = ActiveMcp::Server.new(
  name: "My App MCP Server",
  uri: 'https://your-app.example.com/mcp'
)
server.start
```

Then configure your MCP client:

```json
{
  "mcpServers": {
    "my-rails-app": {
      "command": "/path/to/ruby",
      "args": ["/path/to/script/mcp_server.rb"]
    }
  }
}
```
