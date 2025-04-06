json.jsonrpc ActiveMcp::JSON_RPC_VERSION if @format == :jsonrpc
json.id @id if @format == :jsonrpc && @id.present?

if @format == :jsonrpc
  json.result @tool_result
else
  json.isError @tool_result[:isError] if @tool_result[:isError]
  json.content do
    json.array!(@tool_result[:content]) do |content|
      json.type content[:type]
      json.text raw content[:text]
    end
  end
end
