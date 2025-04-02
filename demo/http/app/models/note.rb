class Note < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true

  def self.search(query)
    [
      {id: 1, title: "会議メモ", content: "プロジェクトについての会議", created_at: Time.now - 2.days},
      {id: 2, title: "買い物リスト", content: "牛乳、パン、卵", created_at: Time.now - 1.day},
      {id: 3, title: "アイデアメモ", content: "新しいアプリのアイデア", created_at: Time.now}
    ].select { |note| note[:title].include?(query) || note[:content].include?(query) }
  end
end
