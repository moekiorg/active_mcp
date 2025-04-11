# Server

Active MCP provides a standalone server implementation that can be used to connect AI assistants to your Rails application.

## Basic Usage

Create and start a server:

```ruby
server = ActiveMcp::Server.new(
  name: "My MCP Server",
  version: "1.0.0",
  uri: "http://localhost:3000/mcp"
)

server.start
```

## Configuration Options

The server accepts the following options:

| Option    | Description                   | Default     |
| --------- | ----------------------------- | ----------- |
| `name`    | Server name shown to clients  | "ActiveMcp" |
| `version` | Server version                | "1.0.0"     |
| `uri`     | URI of the Rails MCP endpoint | nil         |
| `auth`    | Authentication configuration  | nil         |

## Authentication

Configure authentication for the server:

```ruby
server = ActiveMcp::Server.new(
  uri: "http://localhost:3000/mcp",
  auth: {
    type: :bearer,
    token: ENV["MCP_AUTH_TOKEN"]
  }
)
```

Or use basic authentication:

```ruby
server = ActiveMcp::Server.new(
  uri: "http://localhost:3000/mcp",
  auth: {
    type: :basic,
    token: Base64.strict_encode64("#{username}:#{password}")
  }
)
```

## Connection Types

The server supports two types of connections:

1. **Standard I/O**: Use `serve_stdio` for command-line interfaces:

```ruby
server.serve_stdio
```

2. **Custom Connection**: Implement your own connection handler:

```ruby
class MyConnection
  def read_next_message
    # Read incoming message
  end

  def send_message(message)
    # Send response message
  end
end

server.serve(MyConnection.new)
```

## Error Handling

The server includes built-in error handling and logging:

```ruby
begin
  server.start
rescue => e
  ActiveMcp::Server.log_error("Server error", e)
end
```

Server errors are automatically logged to Rails.logger in a Rails environment, or to STDERR otherwise.
