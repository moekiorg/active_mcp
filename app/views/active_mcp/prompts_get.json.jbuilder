json.jsonrpc ActiveMcp::JSON_RPC_VERSION if @format == :jsonrpc
json.id @id if @format == :jsonrpc && @id.present?

json.result do
  json.description @prompt.description
  json.messages @prompt.messages(**params[:params][:arguments].permit!.to_h.symbolize_keys).map(&:to_h)
end
