json.jsonrpc ActiveMcp::JSON_RPC_VERSION if @format == :jsonrpc
json.id @id if @format == :jsonrpc && @id.present?

json.result do
  json.resourceTemplates do
    json.array!(@resource_templates) do |template|
      json.name template.resource_template_name_value
      json.uriTemplate template.uri_template_value
      json.mimeType template.mime_type_value
      json.description template.description_value
    end
  end
end
