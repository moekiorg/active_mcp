class DummyPrompt < ActiveMcp::Prompt::Base
  argument :name, required: true, description: "Name"

  def initialize(greeting:)
    @greeting = greeting
  end

  def prompt_name
    "dummy"
  end

  def description
    "This is a dummy"
  end

  def messages(name:)
    [
      ActiveMcp::Message::Text.new(role: "user", text: "#{@greeting} #{name}"),
      ActiveMcp::Message::Image.new(role: "user", data:
      File.read(Rails.root.join("test", "fixtures", "lena.png")), mime_type: "image/png"),
      ActiveMcp::Message::Audio.new(role: "user", data: File.read(Rails.root.join("test", "fixtures", "sample.mp3")), mime_type: "audio/mpeg"),
      ActiveMcp::Message::Resource.new(role: "user", resource: DummyResource.new(name: "UserA"))
    ]
  end
end
