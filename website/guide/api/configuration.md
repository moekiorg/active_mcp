# Configuration

Active MCP provides the following configuration options:

## Server Configuration

```ruby
ActiveMcp.configure do |config|
  # Name of the MCP server
  config.server_name = "My MCP Server"

  # Server version
  config.server_version = "1.0.0"
end
```

## Authentication Configuration

When using a standalone server, you can configure authentication as follows:

```ruby
server = ActiveMcp::Server.new(
  name: "My Secure MCP Server",
  uri: 'http://localhost:3000/mcp',
  auth: {
    type: :bearer,
    token: ENV['MCP_AUTH_TOKEN']
  }
)
```

## Available Configuration Options

| Option         | Description            | Default Value |
| -------------- | ---------------------- | ------------- |
| server_name    | Name of the MCP server | "MCP Server"  |
| server_version | Server version number  | "1.0.0"       |
