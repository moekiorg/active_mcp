class WeatherTool < ActiveMcp::Tool
  description "指定した都市の天気情報を取得します"

  argument :city, :string, required: true, description: "天気を取得する都市名"
  argument :country, :string, required: false, description: "国名（オプション）"

  def call(city:, country: nil, auth_info: nil, **args)

    weather_data = get_mock_weather_data(city, country)

    if weather_data
      format_weather_response(weather_data)
    else
      "指定された都市の天気情報が見つかりませんでした: #{city}"
    end
  end

  private

  def get_mock_weather_data(city, country)
    mock_data = {
      "tokyo" => {
        temperature: 23,
        condition: "晴れ",
        humidity: 45,
        wind: "5m/s"
      },
      "osaka" => {
        temperature: 25,
        condition: "曇り",
        humidity: 60,
        wind: "3m/s"
      },
      "sapporo" => {
        temperature: 18,
        condition: "雨",
        humidity: 80,
        wind: "7m/s"
      },
      "fukuoka" => {
        temperature: 27,
        condition: "晴れ",
        humidity: 50,
        wind: "4m/s"
      }
    }

    city_key = city.downcase
    mock_data[city_key]
  end

  def format_weather_response(weather_data)
    <<~TEXT
      🌤️ 天気情報:
      
      気温: #{weather_data[:temperature]}°C
      状態: #{weather_data[:condition]}
      湿度: #{weather_data[:humidity]}%
      風速: #{weather_data[:wind]}
    TEXT
  end
end
