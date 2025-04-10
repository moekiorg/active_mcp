json.jsonrpc ActiveMcp::JSON_RPC_VERSION if @format == :jsonrpc
json.id @id if @format == :jsonrpc && @id.present?

json.result do
  json.tools do
    json.array!(@tools) do |tool|
      json.name tool.tool_name_value
      json.description tool.description_value
      json.inputSchema tool.schema
    end
  end
end
