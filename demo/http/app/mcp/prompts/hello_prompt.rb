class HelloPrompt < ActiveMcp::Prompt::Base
  def initialize(greeting:)
    @greeting = greeting
  end

  def prompt_name
    "hello"
  end

  def description
    "This is a test"
  end

  def messages
    [
      ActiveMcp::Message::Text.new(role: "user", text: "#{@greeting} #{"a"}"),
      ActiveMcp::Message::Image.new(role: "user", data:
      File.read(Rails.root.join("public", "lena.png")), mime_type: "image/png"),
      ActiveMcp::Message::Audio.new(role: "user", data: File.read(Rails.root.join("public", "sample.mp3")), mime_type: "audio/mpeg"),
      ActiveMcp::Message::Resource.new(role: "user", resource: UserResource.new(name: "UserA"))
    ]
  end
end
