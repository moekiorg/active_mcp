json.jsonrpc ActiveMcp::JSON_RPC_VERSION if @format == :jsonrpc
json.id @id if @format == :jsonrpc && @id.present?

json.result do
  json.tools do
    json.array!(@tools) do |tool|
      json.name tool.tool_name
      json.description tool.description
      json.inputSchema tool.class.schema
    end
  end
end
