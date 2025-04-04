require 'cgi'

class SecureNotesTool < ActiveMcp::Tool
  description "認証済みユーザーのみが利用できる安全なメモ機能"

  property :action, :string, required: true, description: "アクション（list, create, read, delete）"
  property :note_id, :string, required: false, description: "ノートID（read, deleteで必要）"
  property :title, :string, required: false, description: "ノートタイトル（createで必要）"
  property :content, :string, required: false, description: "ノート内容（createで必要）"

  def self.authorized?(auth_info)
    return false unless auth_info
    return false unless auth_info[:type] == :bearer
    auth_info[:token] == "valid-token" || auth_info[:token] == "admin-token"
  end

  def call(action:, note_id: nil, title: nil, content: nil, auth_info: nil, **args)
    unless auth_info.present?
      return "この機能は認証されたユーザーのみ利用できます"
    end

    auth_type = auth_info[:type]
    token = auth_info[:token]

    valid_token = ENV["API_TOKEN"] || "valid-token-dev-only"
    unless auth_type == :bearer && token == valid_token
      return "無効な認証情報です"
    end

    case action.downcase
    when "list"
      list_notes
    when "create"
      validate_create_params(title, content)
      create_note(title, content)
    when "read"
      validate_note_id(note_id)
      read_note(note_id)
    when "delete"
      validate_note_id(note_id)
      delete_note(note_id)
    else
      return "不明なアクション: #{action}。サポートされているアクションは list, create, read, delete です。"
    end
  end

  private

  def validate_create_params(title, content)
    return "ノートの作成にはtitleパラメータが必要です" if title.blank?
    return "ノートの作成にはcontentパラメータが必要です" if content.blank?
  end

  def validate_note_id(note_id)
    return "note_idパラメータが必要です" if note_id.blank?
    return "指定されたIDのノートが見つかりません: #{note_id}" unless get_mock_notes.key?(note_id)
  end

  def list_notes
    notes = get_mock_notes

    response = "🔒 安全なノート一覧:\n\n"

    if notes.empty?
      response += "ノートはまだ作成されていません。"
    else
      notes.each do |id, note|
        response += "ID: #{id} - #{CGI.escapeHTML(note[:title].to_s)}\n"
      end
    end

    response
  end

  def create_note(title, content)
    note_id = SecureRandom.hex(4)

    "✅ ノートが作成されました！\n\nID: #{note_id}\nタイトル: #{CGI.escapeHTML(title.to_s)}"
  end

  def read_note(note_id)
    note = get_mock_notes[note_id]

    "📝 ノート内容:\n\nタイトル: #{CGI.escapeHTML(note[:title].to_s)}\n\n#{CGI.escapeHTML(note[:content].to_s)}"
  end

  def delete_note(note_id)
    "🗑️ ノート（ID: #{note_id}）が削除されました。"
  end

  def get_mock_notes
    {
      "1234" => {
        title: "重要な会議メモ",
        content: "4月10日の会議について：\n- プロジェクトの進捗確認\n- 次のマイルストーン設定\n- 予算の見直し"
      },
      "5678" => {
        title: "買い物リスト",
        content: "- 牛乳\n- パン\n- 卵\n- 野菜"
      },
      "abcd" => {
        title: "旅行計画",
        content: "夏休みの旅行案：\n1. 沖縄（7月）\n2. 北海道（8月）\n3. 京都（9月）"
      }
    }
  end
end
