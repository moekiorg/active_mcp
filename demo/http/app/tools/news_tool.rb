class NewsTool < ActiveMcp::Tool
  description "指定したカテゴリの最新ニュースを取得します"

  property :category, :string, required: true, description: "ニュースカテゴリ（tech, business, sports, etc.）"
  property :limit, :integer, required: false, description: "取得するニュース数の上限"

  def call(category:, limit: 5, auth_info: nil, **args)
    user_info = if auth_info.present?
      "（認証ユーザー: #{auth_info[:type]} 認証）"
    else
      "（匿名ユーザー）"
    end

    news_items = get_mock_news(category, limit)

    if news_items.empty?
      raise "指定されたカテゴリのニュースが見つかりませんでした: #{category}"
    end

    {
      type: "text",
      content: format_news_response(category, news_items, user_info)
    }
  end

  private

  def get_mock_news(category, limit)
    mock_data = {
      "tech" => [
        {title: "AI技術の最新動向", summary: "最新のAI技術のトレンドについての詳細レポート"},
        {title: "新型スマートフォンの発売日が決定", summary: "次世代モデルは来月発売予定"},
        {title: "プログラミング言語のランキング発表", summary: "人気のプログラミング言語トップ10"},
        {title: "クラウドサービスの市場規模が拡大", summary: "クラウド市場は前年比20%増"},
        {title: "オープンソースプロジェクトの動向", summary: "注目のオープンソースプロジェクト特集"}
      ],
      "business" => [
        {title: "株式市場の動向分析", summary: "主要指標の先週の動きと今週の見通し"},
        {title: "大手企業の四半期決算発表", summary: "予想を上回る好決算を発表"},
        {title: "新興企業への投資状況", summary: "ベンチャーキャピタルの投資動向"},
        {title: "国際貿易の最新情報", summary: "貿易協定の進展状況について"},
        {title: "業界再編の動き", summary: "大手企業の合併・買収の最新情報"}
      ],
      "sports" => [
        {title: "サッカーリーグの試合結果", summary: "週末の主要試合のハイライト"},
        {title: "野球選手の移籍情報", summary: "注目選手の契約更新と移籍の噂"},
        {title: "テニス大会の最新情報", summary: "グランドスラム大会の準備状況"},
        {title: "オリンピック代表選手の特集", summary: "注目の選手たちのプロフィール"},
        {title: "eスポーツ大会の結果", summary: "先週末の大会で優勝したチーム"}
      ]
    }

    category_news = mock_data[category.downcase] || []
    category_news.take(limit)
  end

  def format_news_response(category, news_items, user_info)
    response = "📰 #{category.upcase}カテゴリの最新ニュース #{user_info}\n\n"

    news_items.each_with_index do |item, index|
      response += "#{index + 1}. #{item[:title]}\n"
      response += "   #{item[:summary]}\n\n"
    end

    response
  end
end
