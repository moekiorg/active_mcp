require_relative "../../lib/active_mcp"

server = ActiveMcp::Server.new(
  name: "ActiveMcp DEMO",
  uri: ENV["URL"] || "http://localhost:3000/mcp",
  auth: {
    type: :bearer,
    token: ENV["ACCESS_TOKEN"]
  }
)

server.serve_stdio
