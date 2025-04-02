class NoteSearchTool < ActiveMcp::Tool
  description "ノートを検索します"

  property :query, :string, required: true, description: "検索キーワード"
  property :limit, :integer, required: false, description: "結果の最大数"

  def call(query:, limit: 10, auth_info: nil, **args)
    user_info = if auth_info.present?
      "（認証ユーザー: #{auth_info[:user][:name] if auth_info[:user]}）"
    else
      "（匿名ユーザー）"
    end

    notes = Note.search(query)

    if notes.empty?
      result = "検索キーワード「#{query}」に一致するノートが見つかりませんでした。"
    else
      result = "「#{query}」の検索結果 #{user_info}:\n\n"

      notes.take(limit).each do |note|
        result += "📝 #{note[:title]}\n"
        result += "   #{note[:content]}\n"
        result += "   #{note[:created_at].strftime("%Y-%m-%d %H:%M")}\n\n"
      end
    end

    {
      type: "text",
      content: result
    }
  end
end
