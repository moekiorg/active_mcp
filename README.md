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
  - [🔌 MCP Connection Methods](#-mcp-connection-methods)
    - [1. Direct HTTP Connection](#1-direct-http-connection)
    - [2. Standalone MCP Server](#2-standalone-mcp-server)
  - [🛠 Rails Generators](#-rails-generators)
    - [Install Generator](#install-generator)
    - [Tool Generator](#tool-generator)
    - [Resource Generator](#resource-generator)
  - [🧰 Creating MCP Tools](#-creating-mcp-tools)
  - [📋 Input Schema](#-input-schema)
  - [🔐 Authorization \& Authentication](#-authorization--authentication)
    - [Authorization for Tools](#authorization-for-tools)
    - [Authentication Options](#authentication-options)
      - [1. Server Configuration](#1-server-configuration)
      - [2. Token Verification in Tools](#2-token-verification-in-tools)
  - [📦 MCP Resources](#-mcp-resources)
    - [Creating Resources](#creating-resources)
    - [Resource Types](#resource-types)
  - [📦 MCP Resource Templates](#-mcp-resource-templates)
    - [Creating Resource Templates](#creating-resource-templates)
  - [💬 MCP Prompts](#-mcp-prompts)
    - [Creating Prompt](#creating-prompt)
  - [📥 Using Context in the Schema](#-using-context-in-the-schema)
  - [💡 Best Practices](#-best-practices)
    - [1. Create Specific Tool Classes](#1-create-specific-tool-classes)
    - [2. Validate and Sanitize Inputs](#2-validate-and-sanitize-inputs)
    - [3. Return Structured Responses](#3-return-structured-responses)
  - [🧪 Development](#-development)
  - [👥 Contributing](#-contributing)
  - [📄 License](#-license)

## ✨ Features

- **Simple Integration**: Easily expose Rails functionality as MCP tools
- **Resource Support**: Share files and data with AI assistants through MCP resources
- **Powerful Generators**: Quickly scaffold MCP tools and resources with Rails generators
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

1. Initialize

The easiest way to set up Active MCP in your Rails application is to use the install generator:

```bash
$ rails generate active_mcp:install
```

This generator will create a configuration initializer at `config/initializers/active_mcp.rb`

2. Create a tool by inheriting from `ActiveMcp::Tool::Base`:

```bash
$ rails generate active_mcp:tool create_note
```

```ruby
class CreateNoteTool < ActiveMcp::Tool::Base
  def tool_name
    "create_note"
  end

  def description
    "Create Note"
  end

  argument :title, :string, required: true
  argument :content, :string, required: true

  def call(title:, content:, context:)
    note = Note.create(title: title, content: content)

    "Created note with ID: #{note.id}"
  end
end
```

3. Create schema for your application:

```ruby
class MySchema < ActiveMcp::Schema::Base
  def tools
    [
      CreateNoteTool.new
    ]
  end
end
```

4. Create controller ans set up routing:

```ruby
class MyMcpController < ActiveMcp::BaseController

  private

  def schema
    MySchema.new(context:)
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

This creates a new tool file at `app/mcp/tools/search_users_tool.rb` with ready-to-customize starter code.

### Resource Generator

Generate new MCP resources to share data with AI:

```bash
$ rails generate active_mcp:resource profile_image
```

This creates a new resource file at `app/mcp/resources/profile_image_resource.rb` that you can customize to provide various types of content to AI assistants.

## 🧰 Creating MCP Tools

MCP tools are Ruby classes that inherit from `ActiveMcp::Tool::Base` and define an interface for AI to interact with your application:

```ruby
class SearchUsersTool < ActiveMcp::Tool::Base
  def tool_name
    "Search Users"
  end

  def description
    'Search users by criteria'
  end

  argument :email, :string, required: false, description: 'Email to search for'
  argument :name, :string, required: false, description: 'Name to search for'
  argument :limit, :integer, required: false, description: 'Maximum number of records to return'

  def call(email: nil, name: nil, limit: 10, context: {})
    criteria = {}
    criteria[:email] = email if email.present?
    criteria[:name] = name if name.present?

    users = User.where(criteria).limit(limit)

    users.attributes
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

| Type       | Description                     |
| ---------- | ------------------------------- |
| `:string`  | Text values                     |
| `:integer` | Whole numbers                   |
| `:number`  | Decimal numbers (float/decimal) |
| `:boolean` | True/false values               |
| `:array`   | Lists of values                 |
| `:object`  | Hash/dictionary structures      |
| `:null`    | Null values                     |

## 🔐 Authorization & Authentication

### Authorization for Tools

Control access to tools by overriding the `visible?` class method:

```ruby
class AdminOnlyTool < ActiveMcp::Tool::Base
  def tool_name
    "admin_only_tool"
  end

  def description
    "Admin-only tool"
  end

  argument :command, :string, required: true, description: "Admin command"

  # Only allow admins to access this tool
  def visible?(context:)
    return false unless context
    return false unless context[:auth_info][:type] == :bearer

    # Check if the token belongs to an admin
    context[:auth_info] == "admin-token" || User.find_by_token(context[:auth_info])&.admin?
  end

  def call(command:, context: {})
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
def call(resource_id:, context: {})
  # Check if authentication is provided
  unless context[:auth_info].present?
    raise "Authentication required"
  end

  # Verify the token
  user = User.authenticate_with_token(context[:auth_info][:token])

  unless user
    raise "Invalid authentication token"
  end

  # Proceed with authenticated operation
  # ...
end
```

## 📦 MCP Resources

MCP Resources allow you to share data and files with AI assistants. Resources have a URI, MIME type, and can return either text or binary data.

### Creating Resources

Resources are Ruby classes `**Resource`:

```ruby
class UserResource < ActiveMcp::Resource::Base
  def initialize(id:)
    @user = User.find(id)
  end

  def resource_name
    @user.name
  end

  def uri
    "data://localhost/users/#{@user.id}"
  end

  def mime_type
    "application/json"
  end

  def description
    @user.profile
  end

  def visible?(context:)
    # Your logic...
  end

  def text
    # Return JSON data
    {
      id: @user.id,
      name: @user.name,
      email: @user.email,
      created_at: @user.created_at
    }
  end
end
```

```ruby
class MySchema < ActiveMcp::Schema::Base
  def resources
    User.all.each do |user|
      UserResource.new(id: user.id)
    end
  end
end
```

### Resource Types

Resources can return two types of content:

1. **Text Content** - Use the `text` method to return structured data:

```ruby
def text
  # Return strings, arrays, hashes, or any JSON-serializable object
  { items: Product.all.map(&:attributes) }
end
```

2. **Binary Content** - Use the `blob` method to return binary files:

```ruby
class ImageResource < ActiveMcp::Resource::Base
  class << self
    def mime_type
      "image/png"
    end
  end

  def resource_name
    "profile_image"
  end

  def uri
    "data://localhost/image"
  end

  def description
    "Profile image"
  end

  def blob
    # Return binary file content
    File.read(Rails.root.join("public", "profile.png"))
  end
end
```

Resources can be protected using the same authorization mechanism as tools:

```ruby
def visible?(context: {})
  return false unless context
  return false unless context[:auth_info][:type] == :bearer

  # Check if the token belongs to an admin
  User.find_by_token(context[:auth_info][:token])&.admin?
end
```

## 📦 MCP Resource Templates

MCP Resource Teamplates allow you to define template of resources.

### Creating Resource Templates

Resource teamplates are Ruby classes `**Resource`:

```ruby
class UserResource < ActiveMcp::Resource::Base
  class << self
    def resource_template_name
      "users"
    end

    def uri_template
      "data://localhost/users/{id}"
    end

    def mime_type
      "application/json"
    end

    def description
      "This is a test."
    end

    def visible?(context:)
      # Your logic...
    end
  end

  argument :id, complete: ->(value, context) do
    User.all.pluck(:id).filter { _1.match(value) }
  end

  def initialize(id:)
    @user = User.find(id)
  end

  def resource_name
    @user.name
  end

  def description
    @user.profile
  end

  def uri
    "data://localhost/users/#{@user.name}"
  end

  def text
    { name: @user.name }
  end
end
```

```ruby
class MySchema < ActiveMcp::Schema::Base
  def resources
    User.all.each do |user|
      UserResource.new(id: user.id)
    end
  end
end
```

## 💬 MCP Prompts

MCP Prompts allow you to define prompt set.

### Creating Prompt

Resources are Ruby classes `**Prompt`:

```ruby
class HelloPrompt < ActiveMcp::Prompt::Base
  argument :name, required: true, description: "User name", complete: ->(value, context) do
    User.all.pluck(:name).filter { _1.match(value) }
  end

  def initialize(greeting:)
    @greeting = greeting
  end

  def prompt_name
    "hello"
  end

  def description
    "This is a test."
  end

  def visible?(context:)
    # Your logic...
  end

  def messages(name:)
    [
      ActiveMcp::Message::Text.new(
        role: "user",
        text: "#{@greeting} #{name}"
      ),
      ActiveMcp::Message::Image.new(
        role: "assistant",
        data: File.read(file),
        mime_type: "image/png"
      ),
      ActiveMcp::Message::Audio.new(
        role: "user",
        data: File.read(file),
        mime_type: "audio/mpeg"
      ),
      ActiveMcp::Message::Resource.new(
        role: "assistant",
        resource: UserResource.new(name: @name)
      )
    ]
  end
end
```

```ruby
class MySchema < ActiveMcp::Schema::Base
  def prompts
    [
      HelloPrompt.new(greeting: "Hello!")
    ]
  end
end
```

## 📥 Using Context in the Schema

```ruby
class MySchema < ActiveMcp::Schema::Base
  def prompts
    user = User.find_by_token(context[:auth_info][:token])

    user.greetings.map do |greeting|
      GreetingPrompt.new(greeting: greeting)
    end
  end
end
```

```ruby
class GreetingPrompt < ActiveMcp::Prompt::Base
  def initialize(greeting:)
    @greeting = greeting
  end

  def prompt_name
    "greeting_#{@greeting.text}"
  end

  def messages
    # ...
  end
end
```

## 💡 Best Practices

### 1. Create Specific Tool Classes

Create dedicated tool classes for each model or operation instead of generic tools:

```ruby
# ✅ GOOD: Specific tool for a single purpose
class SearchUsersTool < ActiveMcp::Tool::Base
  # ...specific implementation
end

# ❌ BAD: Generic tool that dynamically loads models
class GenericSearchTool < ActiveMcp::Tool::Base
  # Avoid this pattern - security and maintainability issues
end
```

### 2. Validate and Sanitize Inputs

Always validate and sanitize inputs in your tool implementations:

```ruby
def call(user_id:, context: {})
  # Validate input
  unless user_id.is_a?(Integer) || user_id.to_s.match?(/^\d+$/)
    raise "Invalid user ID format"
  end

  # Proceed with validated data
  user = User.find_by(id: user_id)
  # ...
end
```

### 3. Return Structured Responses

Return structured responses that are easy for AI to parse:

```ruby
def call(query:, context: {})
  results = User.search(query)

  {
    content: results.to_json(only: [:id, :name, :email]),
    metadata: {
      count: results.size,
      query: query
    }
  }
end
```

## 🧪 Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake` to run the tests.

## 👥 Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moekiorg/active_mcp. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/moekiorg/active_mcp/blob/main/CODE_OF_CONDUCT.md).

## 📄 License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
