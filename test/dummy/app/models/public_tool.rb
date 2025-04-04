class PublicTool < ActiveMcp::Tool
  description "A public tool that can be accessed without authentication"

  property :query, :string, required: true, description: "Search query"

  def call(query:, auth_info: nil)
    "Public search result for: #{query}"
  end
end
