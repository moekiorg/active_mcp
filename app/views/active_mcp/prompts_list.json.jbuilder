json.jsonrpc ActiveMcp::JSON_RPC_VERSION if @format == :jsonrpc
json.id @id if @format == :jsonrpc && @id.present?

json.result do
  json.prompts do
    json.array!(@prompts) do |prompt|
      json.name prompt.prompt_name_value
      json.description prompt.description_value
      json.arguments prompt.arguments ? prompt.arguments.map { _1.except(:complete) } : []
    end
  end
end
