class NoArgumentPrompt < ActiveMcp::Prompt::Base
  prompt_name "dummy"

  description "This is a dummy"

  def messages
    [
      ActiveMcp::Message::Text.new(role: "user", text: "#{@greeting} user"),
      ActiveMcp::Message::Image.new(role: "user", data:
      File.read(Rails.root.join("test", "fixtures", "lena.png")), mime_type: "image/png"),
      ActiveMcp::Message::Audio.new(role: "user", data: File.read(Rails.root.join("test", "fixtures", "sample.mp3")), mime_type: "audio/mpeg"),
      ActiveMcp::Message::Resource.new(role: "user", resource: DummyResource.new(name: "UserA"))
    ]
  end
end
