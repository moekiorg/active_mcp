json.jsonrpc ActiveMcp::JSON_RPC_VERSION if @format == :jsonrpc
json.id @id if @format == :jsonrpc && @id.present?

json.result do
  json.resourceTemplates do
    json.array!(@resource_templates) do |resource|
      json.name resource.resource_template_name
      json.uriTemplate resource.uri_template
      json.mimeType resource.mime_type
      json.description resource.description
    end
  end
end
