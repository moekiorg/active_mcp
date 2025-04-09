class DemoSchema < ActiveMcp::Schema::Base
  def resources
    user_resources = ["UserA", "UserB"].map do |username|
      UserResource.new(name: username)
    end

    [*user_resources, ImageResource.new]
  end

  def tools
    [
      NewsTool.new,
      WeatherTool.new
    ]
  end

  def prompts
    [
      HelloPrompt.new(greeting: "Hello!")
    ]
  end
end
