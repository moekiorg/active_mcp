class WeatherTool < ActiveMcp::Tool::Base
  tool_name "weather"

  description "Get weather information for the specified city"

  argument :city, :string, required: true, description: "City name to get weather information"
  argument :country, :string, required: false, description: "Country name (optional)"

  def call(city:, country: nil, context: {})
    weather_data = get_mock_weather_data(city, country)

    [{
      type: "text",
      text: weather_data || "Weather information not found for the specified city: #{city}"
    }]
  end

  private

  def get_mock_weather_data(city, country)
    mock_data = {
      "tokyo" => {
        temperature: 23,
        condition: "sunny",
        humidity: 45,
        wind: "5m/s"
      },
      "osaka" => {
        temperature: 25,
        condition: "cloudy",
        humidity: 60,
        wind: "3m/s"
      },
      "sapporo" => {
        temperature: 18,
        condition: "rain",
        humidity: 80,
        wind: "7m/s"
      },
      "fukuoka" => {
        temperature: 27,
        condition: "sunny",
        humidity: 50,
        wind: "4m/s"
      }
    }

    city_key = city.downcase
    mock_data[city_key]
  end
end
