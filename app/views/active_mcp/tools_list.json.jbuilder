json.jsonrpc ActiveMcp::JSON_RPC_VERSION if @format == :jsonrpc
json.id @id if @format == :jsonrpc && @id.present?

if @format == :jsonrpc
  json.result do
    json.tools do
      json.array!(@tools) do |tool|
        json.name tool.name
        json.description tool.description
        json.inputSchema tool.class.schema
      end
    end
  end
else
  json.result do
    json.array!(@tools) do |tool|
      json.name tool.name
      json.description tool.description
      json.inputSchema tool.class.schema
    end
  end
end
