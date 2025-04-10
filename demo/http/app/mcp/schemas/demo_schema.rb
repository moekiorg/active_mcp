class DemoSchema < ActiveMcp::Schema::Base
  resource UserResource, items: [
    {name: "UserA"},
    {name: "UserB"}
  ]
  resource ImageResource

  tool NewsTool
  tool WeatherTool

  prompt HelloPrompt
end
