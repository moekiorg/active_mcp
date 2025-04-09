class HelloPrompt < ActiveMcp::Prompt::Base
  argument :name, required: true, description: "Name", complete: ->(value) do
    ["UserA", "UserB"].filter { _1.match(value) }
  end

  def initialize(greeting:)
    @greeting = greeting
  end

  def prompt_name
    "hello"
  end

  def description
    "This is a test"
  end

  def messages(name:)
    [
      ActiveMcp::Message::Text.new(role: "user", text: "#{@greeting} #{name}"),
      ActiveMcp::Message::Image.new(role: "user", data:
      File.read(Rails.root.join("public", "lena.png")), mime_type: "image/png"),
      ActiveMcp::Message::Audio.new(role: "user", data: File.read(Rails.root.join("public", "sample.mp3")), mime_type: "audio/mpeg"),
      ActiveMcp::Message::Resource.new(role: "user", resource: UserResource.new(name: "UserA"))
    ]
  end
end
