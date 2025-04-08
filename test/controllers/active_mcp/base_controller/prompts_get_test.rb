require "test_helper"

module ActiveMcp
  class BaseController
    class PromptsGetTest < ActionController::TestCase
      setup do
        @routes = ActiveMcp::Engine.routes
        @controller = ActiveMcp::BaseController.new

        @schema_class = Class.new(ActiveMcp::Schema::Base) do
          prompt DummyPrompt
        end
      end

      test "should return resources list" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {method: Method::PROMPTS_GET, params: {
            name: "dummy",
            arguments: {
              name: "UserA"
            }
          }}

          assert_response :success

          json = JSON.parse(response.body, symbolize_names: true)
          assert_equal json, {
            result: {
              description: "This is a dummy",
              messages: [
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
            }
          }
        end
      end

      test "should return resources list when jsonrpc" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {method: Method::PROMPTS_GET, jsonrpc: "2.0", params: {
            name: "dummy",
            arguments: {
              name: "UserA"
            }
          }}

          assert_response :success

          json = JSON.parse(response.body, symbolize_names: true)
          assert_equal json, {
            jsonrpc: "2.0",
            result: {
              description: "This is a dummy",
              messages: [
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
            }
          }
        end
      end
    end
  end
end
