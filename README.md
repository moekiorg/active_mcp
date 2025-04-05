# Active MCP

A Ruby on Rails engine that provides [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) capabilities to Rails applications. This gem allows you to easily create and expose MCP-compatible tools from your Rails application.

## Installation

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

## Setup

### Using the Install Generator (Recommended)

The easiest way to set up Active MCP in your Rails application is to use the install generator:

```bash
$ rails generate active_mcp:install
```

This generator will:

1. Create a configuration initializer at `config/initializers/active_mcp.rb`
2. Mount the ActiveMcp engine in your routes

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
  description "Create Note!!"

  property :title, :string
  property :content, :string

  def call(title:, content:)
    Note.create(title:, content:)

    "Created!"
  end
end
```

#### with streamable HTTP

Set MCP destination to `https:your-app.example.com/mcp`

#### with independent MCP Server

Start the MCP server:

```ruby
# server.rb
server = ActiveMcp::Server.new(
  name: "ActiveMcp DEMO",
  uri: 'https://your-app.example.com/mcp'
)
server.start
```

Set up MCP Client

```json
{
  "mcpServers": {
    "active-mcp-demo": {
      "command": "/path/to/ruby",
      "args": ["/path/to/server.rb"]
    }
  }
}
```

## Rails Generators

Active MCP provides generators to help you quickly set up and extend your MCP integration:

### Install Generator

Initialize Active MCP in your Rails application:

```bash
$ rails generate active_mcp:install
```

This sets up all necessary configuration files and mounts the MCP engine in your routes.

### Tool Generator

Create new MCP tools quickly:

```bash
# Generate a new MCP tool
$ rails generate active_mcp:tool search_users
```

This creates a new tool file at `app/tools/search_users_tool.rb` with the following starter code:

```ruby
class SearchUsersTool < ActiveMcp::Tool
  description 'Search users'

  property :param1, :string, required: true, description: 'First parameter description'
  property :param2, :string, required: false, description: 'Second parameter description'
  # Add more parameters as needed

  def call(param1:, param2: nil, auth_info: nil, **args)
    # auth_info = { type: :bearer, token: 'xxx', header: 'Bearer xxx' }

    # Implement your tool logic here
    "Tool executed successfully with #{param1}"
  end
end
```

You can then customize the generated tool to fit your needs.

## Input Schema

```ruby
property :name, :string, required: true, description: 'User name'
property :age, :integer, required: false, description: 'User age'
property :addresses, :array, required: false, description: 'User addresses'
property :preferences, :object, required: false, description: 'User preferences'
```

Supported types include:

- `:string`
- `:integer`
- `:number` (float/decimal)
- `:boolean`
- `:array`
- `:object` (hash/dictionary)
- `:null`

## Using with MCP Clients

Any MCP-compatible client can connect to your server. The most common way is to provide the MCP server URL:

```
http://your-app.example.com/mcp
```

Clients will discover the available tools and their input schemas automatically through the MCP protocol.

## Authorization & Authentication

ActiveMcp supports both authentication (verifying who a user is) and authorization (controlling what resources they can access).

### Authorization for Tools

You can control which tools are visible and accessible to different users by overriding the `authorized?` class method:

```ruby
class AdminOnlyTool < ActiveMcp::Tool
  description "This tool is only accessible by admins"

  property :command, :string, required: true, description: "Admin command to execute"

  # Define authorization logic - only admin tokens can access this tool
  def self.authorized?(auth_info)
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

When a user makes a request to the MCP server:

1. Only tools that return `true` from their `authorized?` method will be included in the tools list
2. Users can only call tools that they're authorized to use
3. Unauthorized access attempts will return a 403 Forbidden response

This makes it easy to create role-based access control for your MCP tools.

### Authentication Flow

ActiveMcp supports receiving authentication credentials from MCP clients and forwarding them to your Rails application. There are two ways to handle authentication:

### 1. Using Server Configuration

When creating your MCP server, you can pass authentication options that will be included in every request:

```ruby
server = ActiveMcp::Server.new(
  name: "ActiveMcp DEMO",
  uri: 'http://localhost:3000/mcp',
  auth: {
    type: :bearer, # or :basic
    token: ENV[:ACCESS_TOKEN]
  }
)
server.start
```

### 2. Custom Controller with Auth Handling

For more advanced authentication, create a custom controller that handles the authentication flow:

```ruby
class CustomController < ActiveMcpController
  before_action :authenticate

  private

  def authenticate
    # Extract auth from MCP request
    auth_header = request.headers['Authorization']

    if auth_header.present?
      # Process the auth header (Bearer token, etc.)
      token = auth_header.split(' ').last

      # Validate the token against your auth system
      user = User.find_by_token(token)

      unless user
        render_error(-32600, "Authentication failed")
        return false
      end

      # Set current user for tool access
      Current.user = user
    else
      render_error(-32600, "Authentication required")
      return false
    end
  end
end
```

### 3. Using Auth in Tools

Authentication information is automatically passed to your tools through the `auth_info` parameter:

```ruby
class SecuredDataTool < ActiveMcp::Tool
  description 'Access secured data'

  property :resource_id, :string, required: true, description: 'ID of the resource to access'

  def call(resource_id:, auth_info: nil, **args)
    # Check if auth info exists
    unless auth_info.present?
      raise "Authentication required to access this resource"
    end

    # Extract token from auth info
    token = auth_info[:token]

    # Validate token and get user
    user = User.authenticate_with_token(token)

    unless user
      raise "Invalid authentication token"
    end

    # Check if user has access to the resource
    resource = Resource.find(resource_id)

    if resource.user_id != user.id
      raise "Access denied to this resource"
    end

    # Return the secured data
    {
      type: "text",
      content: resource.to_json
    }
  end
end
```

## Advanced Configuration

### Custom Controller

If you need to customize the MCP controller behavior, you can create your own controller that inherits from `ActiveMcpController`:

```ruby
class CustomController < ActiveContexController
  # Add custom behavior, authentication, etc.
end
```

And update your routes:

```ruby
Rails.application.routes.draw do
  post "/mcp", to: "custom_mcp#index"
end
```

## Best Practices

### Create a Tool for Each Model

For security reasons, it's recommended to create specific tools for each model rather than generic tools that dynamically determine the model class. This approach:

1. Increases security by avoiding dynamic class loading
2. Makes your tools more explicit and easier to understand
3. Provides better validation and error handling specific to each model

For example, instead of creating a generic search tool, create specific search tools for each model:

```ruby
# Good: Specific tool for searching users
class SearchUsersTool < ActiveMcp::Tool
  description 'Search users by criteria'

  property :email, :string, required: false, description: 'Email to search for'
  property :name, :string, required: false, description: 'Name to search for'
  property :limit, :integer, required: false, description: 'Maximum number of records to return'

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

# Good: Specific tool for searching posts
class SearchPostsTool < ActiveMcp::Tool
  description 'Search posts by criteria'

  property :title, :string, required: false, description: 'Title to search for'
  property :author_id, :integer, required: false, description: 'Author ID to filter by'
  property :limit, :integer, required: false, description: 'Maximum number of records to return'

  def call(title: nil, author_id: nil, limit: 10)
    criteria = {}
    criteria[:title] = title if title.present?
    criteria[:author_id] = author_id if author_id.present?

    posts = Post.where(criteria).limit(limit)

    {
      type: "text",
      content: posts.to_json(only: [:id, :title, :author_id, :created_at])
    }
  end
end
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kawakamimoeki/active_mcp. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/kawakamimoeki/active_mcp/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
