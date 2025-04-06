# Active MCP 🔌

<div align="center">

[![Gem Version](https://badge.fury.io/rb/active_mcp.svg)](https://badge.fury.io/rb/active_mcp)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Rails](https://img.shields.io/badge/Rails-%3E%3D%206.0.0-red.svg)](https://rubyonrails.org/)

A Ruby on Rails engine for the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) - connect your Rails apps to AI tools with minimal effort.
</div>

## 📖 Table of Contents

- [Active MCP 🔌](#active-mcp-)
  - [📖 Table of Contents](#-table-of-contents)
  - [✨ Features](#-features)
  - [📦 Installation](#-installation)
  - [🚀 Setup](#-setup)
    - [Using the Install Generator (Recommended)](#using-the-install-generator-recommended)
    - [Manual Setup](#manual-setup)
  - [🔌 MCP Connection Methods](#-mcp-connection-methods)
    - [1. Direct HTTP Connection](#1-direct-http-connection)
    - [2. Standalone MCP Server](#2-standalone-mcp-server)
  - [🛠 Rails Generators](#-rails-generators)
    - [Install Generator](#install-generator)
    - [Tool Generator](#tool-generator)
  - [🧰 Creating MCP Tools](#-creating-mcp-tools)
  - [📋 Input Schema](#-input-schema)
  - [🔐 Authorization \& Authentication](#-authorization--authentication)
    - [Authorization for Tools](#authorization-for-tools)
    - [Authentication Options](#authentication-options)
      - [1. Server Configuration](#1-server-configuration)
      - [2. Token Verification in Tools](#2-token-verification-in-tools)
  - [⚙️ Advanced Configuration](#️-advanced-configuration)
    - [Custom Controller](#custom-controller)
  - [💡 Best Practices](#-best-practices)
    - [1. Create Specific Tool Classes](#1-create-specific-tool-classes)
    - [2. Validate and Sanitize Inputs](#2-validate-and-sanitize-inputs)
    - [3. Return Structured Responses](#3-return-structured-responses)
  - [🧪 Development](#-development)
  - [👥 Contributing](#-contributing)
  - [📄 License](#-license)

## ✨ Features

- **Simple Integration**: Easily expose Rails functionality as MCP tools
- **Powerful Generators**: Quickly scaffold MCP tools with Rails generators
- **Authentication Support**: Built-in authentication and authorization capabilities
- **Flexible Configuration**: Multiple deployment and connection options

## 📦 Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_mcp'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install active_mcp
```

## 🚀 Setup

### Using the Install Generator (Recommended)

The easiest way to set up Active MCP in your Rails application is to use the install generator:

```bash
$ rails generate active_mcp:install
```

This generator will:

1. Create a configuration initializer at `config/initializers/active_mcp.rb`
2. Mount the ActiveMcp engine in your routes
3. Create an MCP server script at `script/mcp_server.rb`
4. Show instructions for next steps

After running the generator, follow the displayed instructions to create and configure your MCP tools.

### Manual Setup

If you prefer to set up manually:

1. Mount the ActiveMcp engine in your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount ActiveMcp::Engine, at: "/mcp"

  # Your other routes
end
```

2. Create a tool by inheriting from `ActiveMcp::Tool`:

```ruby
class CreateNoteTool < ActiveMcp::Tool
  description "Create Note"

  argument :title, :string, required: true
  argument :content, :string, required: true

  def call(title:, content:)
    note = Note.create(title: title, content: content)

    "Created note with ID: #{note.id}"
  end
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

## 🛠 Rails Generators

Active MCP provides generators to help you quickly set up and extend your MCP integration:

### Install Generator

Initialize Active MCP in your Rails application:

```bash
$ rails generate active_mcp:install
```

### Tool Generator

Create new MCP tools quickly:

```bash
$ rails generate active_mcp:tool search_users
```

This creates a new tool file at `app/tools/search_users_tool.rb` with ready-to-customize starter code.

## 🧰 Creating MCP Tools

MCP tools are Ruby classes that inherit from `ActiveMcp::Tool` and define an interface for AI to interact with your application:

```ruby
class SearchUsersTool < ActiveMcp::Tool
  description 'Search users by criteria'

  argument :email, :string, required: false, description: 'Email to search for'
  argument :name, :string, required: false, description: 'Name to search for'
  argument :limit, :integer, required: false, description: 'Maximum number of records to return'

  def call(email: nil, name: nil, limit: 10)
    criteria = {}
    criteria[:email] = email if email.present?
    criteria[:name] = name if name.present?

    users = User.where(criteria).limit(limit)

    {
      type: "text",
      content: users.to_json(only: [:id, :name, :email, :created_at])
    }
  end
end
```

## 📋 Input Schema

Define arguments for your tools using the `argument` method:

```ruby
argument :name, :string, required: true, description: 'User name'
argument :age, :integer, required: false, description: 'User age'
argument :addresses, :array, required: false, description: 'User addresses'
argument :preferences, :object, required: false, description: 'User preferences'
```

Supported types:

| Type | Description |
| --- | --- |
| `:string` | Text values |
| `:integer` | Whole numbers |
| `:number` | Decimal numbers (float/decimal) |
| `:boolean` | True/false values |
| `:array` | Lists of values |
| `:object` | Hash/dictionary structures |
| `:null` | Null values |

## 🔐 Authorization & Authentication

### Authorization for Tools

Control access to tools by overriding the `visible?` class method:

```ruby
class AdminOnlyTool < ActiveMcp::Tool
  description "Admin-only tool"

  argument :command, :string, required: true, description: "Admin command"

  # Only allow admins to access this tool
  def self.visible?(auth_info)
    return false unless auth_info
    return false unless auth_info[:type] == :bearer
    
    # Check if the token belongs to an admin
    auth_info[:token] == "admin-token" || User.find_by_token(auth_info[:token])&.admin?
  end

  def call(command:, auth_info: nil)
    # Tool implementation
  end
end
```

### Authentication Options

#### 1. Server Configuration

```ruby
server = ActiveMcp::Server.new(
  name: "My Secure MCP Server",
  uri: 'http://localhost:3000/mcp',
  auth: {
    type: :bearer,
    token: ENV['MCP_AUTH_TOKEN']
  }
)
server.start
```

#### 2. Token Verification in Tools

```ruby
def call(resource_id:, auth_info: nil, **args)
  # Check if authentication is provided
  unless auth_info.present?
    raise "Authentication required"
  end

  # Verify the token
  user = User.authenticate_with_token(auth_info[:token])
  
  unless user
    raise "Invalid authentication token"
  end
  
  # Proceed with authenticated operation
  # ...
end
```

## ⚙️ Advanced Configuration

### Custom Controller

Create a custom controller for advanced needs:

```ruby
class CustomMcpController < ActiveMcp::BaseController
  # Custom MCP handling logic
end
```

Update routes:

```ruby
Rails.application.routes.draw do
  post "/mcp", to: "custom_mcp#index"
end
```

## 💡 Best Practices

### 1. Create Specific Tool Classes

Create dedicated tool classes for each model or operation instead of generic tools:

```ruby
# ✅ GOOD: Specific tool for a single purpose
class SearchUsersTool < ActiveMcp::Tool
  # ...specific implementation
end

# ❌ BAD: Generic tool that dynamically loads models
class GenericSearchTool < ActiveMcp::Tool
  # Avoid this pattern - security and maintainability issues
end
```

### 2. Validate and Sanitize Inputs

Always validate and sanitize inputs in your tool implementations:

```ruby
def call(user_id:, **args)
  # Validate input
  unless user_id.is_a?(Integer) || user_id.to_s.match?(/^\d+$/)
    return { error: "Invalid user ID format" }
  end
  
  # Proceed with validated data
  user = User.find_by(id: user_id)
  # ...
end
```

### 3. Return Structured Responses

Return structured responses that are easy for AI to parse:

```ruby
def call(query:, **args)
  results = User.search(query)
  
  {
    type: "text",
    content: results.to_json(only: [:id, :name, :email]),
    metadata: {
      count: results.size,
      query: query
    }
  }
end
```

## 🧪 Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## 👥 Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moekiorg/active_mcp. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/moekiorg/active_mcp/blob/main/CODE_OF_CONDUCT.md).

## 📄 License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

