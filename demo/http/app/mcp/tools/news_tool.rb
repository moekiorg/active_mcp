class NewsTool < ActiveMcp::Tool::Base
  def tool_name
    "news"
  end

  def description
    "Get latest news from specified category"
  end

  argument :category, :string, required: true, description: "News category (tech, business, sports, etc.)"
  argument :limit, :integer, required: false, description: "Maximum number of news items to retrieve"

  def call(category:, limit: 5, auth_info: nil, **args)
    user_info = if auth_info.present?
      "(Authenticated User: #{auth_info[:type]} Auth)"
    else
      "(Anonymous User)"
    end

    news_items = get_mock_news(category, limit)

    if news_items.empty?
      return "No news found for the specified category: #{category}"
    end

    format_news_response(category, news_items, user_info)
  end

  private

  def get_mock_news(category, limit)
    mock_data = {
      "tech" => [
        {title: "Latest AI Technology Trends", summary: "Detailed report on latest AI technology trends"},
        {title: "New Smartphone Release Date Announced", summary: "Next-gen model scheduled for release next month"},
        {title: "Programming Language Rankings Released", summary: "Top 10 popular programming languages"},
        {title: "Cloud Service Market Expands", summary: "Cloud market grows 20% year-over-year"},
        {title: "Open Source Project Trends", summary: "Featured open source projects spotlight"}
      ],
      "business" => [
        {title: "Stock Market Analysis", summary: "Major indicators' movement last week and outlook"},
        {title: "Major Companies' Quarterly Earnings", summary: "Earnings exceed expectations"},
        {title: "Startup Investment Status", summary: "Venture capital investment trends"},
        {title: "International Trade Updates", summary: "Progress on trade agreements"},
        {title: "Industry Restructuring", summary: "Latest on major corporate mergers and acquisitions"}
      ],
      "sports" => [
        {title: "Soccer League Results", summary: "Weekend major match highlights"},
        {title: "Baseball Player Transfer News", summary: "Contract renewals and transfer rumors of notable players"},
        {title: "Tennis Tournament Updates", summary: "Grand Slam tournament preparations"},
        {title: "Olympic Team Feature", summary: "Profiles of notable athletes"},
        {title: "Esports Tournament Results", summary: "Championship team from last weekend's tournament"}
      ]
    }

    category_news = mock_data[category.downcase] || []
    category_news.take(limit)
  end

  def format_news_response(category, news_items, user_info)
    response = "📰 Latest News in #{category.upcase} Category #{user_info}\n\n"

    news_items.each_with_index do |item, index|
      response += "#{index + 1}. #{item[:title]}\n"
      response += "   #{item[:summary]}\n\n"
    end

    response
  end
end
