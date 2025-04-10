json.jsonrpc ActiveMcp::JSON_RPC_VERSION if @format == :jsonrpc
json.id @id if @format == :jsonrpc && @id.present?

json.result do
  json.resources do
    json.array!(@resources) do |resource|
      json.name resource.resource_name
      json.uri resource.uri
      json.mimeType resource.class.mime_type_value
      json.description resource.description
    end
  end
end
