json.jsonrpc ActiveMcp::JSON_RPC_VERSION if @format == :jsonrpc
json.id @id if @format == :jsonrpc && @id.present?

json.result do
  json.description @prompt.class.description
  json.messages @prompt.messages.map(&:to_h)
end
