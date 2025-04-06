json.jsonrpc ActiveMcp::JSON_RPC_VERSION
json.id @id
json.result do
  json.protocolVersion ActiveMcp::PROTOCOL_VERSION
  json.capabilities do
    json.logging Hash.new
    json.capabilities do
      json.resources do
        json.subscribe false
        json.listChanged false
      end
      json.tools do
        json.listChanged false
      end
    end
  end
  json.serverInfo do
    json.name ActiveMcp.config.respond_to?(:server_name) ? ActiveMcp.config.server_name : "Active MCP Server"
    json.version ActiveMcp.config.respond_to?(:server_version) ? ActiveMcp.config.server_version : ActiveMcp::VERSION
  end
end