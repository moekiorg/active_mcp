class DemoSchema < ActiveMcp::Schema::Base
  ["UserA", "UserB"].each do |username|
    resource UserResource.new(name: username)
  end

  resource ImageResource.new

  tool NewsTool.new
  tool WeatherTool.new

  prompt HelloPrompt
end
