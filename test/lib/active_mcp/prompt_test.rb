require "test_helper"

module ActiveMcp
  class PromptTest < ActiveSupport::TestCase
    test "should return messages" do
      prompt = DummyPrompt.new
      assert_equal prompt.messages(greeting: "Hello!", name: "UserA").map(&:to_h), [
        {
          role: "user",
          content: {
            type: "text",
            text: "Hello! UserA"
          }
        },
        {
          role: "user",
          content: {
            type: "image",
            data: Base64.strict_encode64(File.read(Rails.root.join("test", "fixtures", "lena.png"))),
            mimeType: "image/png"
          }
        },
        {
          role: "user",
          content: {
            type: "audio",
            data: Base64.strict_encode64(File.read(Rails.root.join("test", "fixtures", "sample.mp3"))),
            mimeType: "audio/mpeg"
          }
        },
        {
          role: "user",
          content: {
            type: "resource",
            resource: {
              uri: "data://app/users/UserA",
              mimeType: "application/json",
              text: "Hello! UserA"
            }
          }
        }
      ]
    end

    test "should return visible state" do
      prompt = DummyPrompt.new
      assert_equal prompt.visible?, true
    end

    test "should raise error when #message is not defined" do
      prompt_class = Class.new(ActiveMcp::Prompt::Base) {}
      assert_raises NotImplementedError do
        prompt_class.new.messages
      end
    end
  end
end
