json.jsonrpc ActiveMcp::JSON_RPC_VERSION if @format == :jsonrpc
json.id @id if @format == :jsonrpc && @id.present?

if @format == :jsonrpc
  json.result do
    json.completion do
      json.values @completion[:values]
      json.total @completion[:total]
    end
  end
else
  json.result do
    json.values @completion[:values]
    json.total @completion[:total]
  end
end
