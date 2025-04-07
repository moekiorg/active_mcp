class DemoSchema < ActiveMcp::Schema::Base
  ["UserA", "UserB"].each do |username|
    resource UserResource.new(name: username)
  end

  resource ImageResource.new

  resource_template PostResourceTemplate.new

  tool NewsTool.new
  tool WeatherTool.new
end
