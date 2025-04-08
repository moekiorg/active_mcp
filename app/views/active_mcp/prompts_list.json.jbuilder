json.jsonrpc ActiveMcp::JSON_RPC_VERSION if @format == :jsonrpc
json.id @id if @format == :jsonrpc && @id.present?

json.result do
  json.prompts do
    json.array!(@prompts) do |prompt|
      json.name prompt.prompt_name
      json.description prompt.description
      json.arguments prompt.arguments.map { _1.except(:complete) }
    end
  end
end
