json.jsonrpc ActiveMcp::JSON_RPC_VERSION if @format == :jsonrpc
json.id @id if @format == :jsonrpc && @id.present?

if @format == :jsonrpc
  json.result @resource
else
  json.isError @resource[:isError] if @resource[:isError]
  json.contents do
    json.array!(@resource[:contents]) do |content|
      json.uri content[:uri]
      json.mimeType raw content[:mimeType]
      json.text raw content[:text] if content[:text]
      json.blob content[:blob] if content[:blob]
    end
  end
end
