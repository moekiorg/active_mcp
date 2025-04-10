require "test_helper"

module ActiveMcp
  class BaesController
    class PromptsListTest < ActionController::TestCase
      setup do
        @routes = ActiveMcp::Engine.routes
        @controller = ActiveMcp::BaseController.new

        @schema_class = Class.new(ActiveMcp::Schema::Base) do
          prompt DummyPrompt
        end
      end

      test "should return prompts list" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {method: Method::PROMPTS_LIST}

          assert_response :success

          json = JSON.parse(response.body, symbolize_names: true)
          assert_equal json, {
            result: {
              prompts: [
                {
                  name: "dummy",
                  description: "This is a dummy",
                  arguments: [
                    {
                      name: "greeting",
                      description: "Greeting",
                      required: true
                    },
                    {
                      name: "name",
                      description: "Name",
                      required: true
                    }
                  ]
                }
              ]
            }
          }
        end
      end

      test "should return prompts list when jsonrpc" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {method: Method::PROMPTS_LIST, jsonrpc: "2.0"}

          assert_response :success

          json = JSON.parse(response.body, symbolize_names: true)
          assert_equal json, {
            jsonrpc: "2.0",
            result: {
              prompts: [
                {
                  name: "dummy",
                  description: "This is a dummy",
                  arguments: [
                    {
                      name: "greeting",
                      description: "Greeting",
                      required: true
                    },
                    {
                      name: "name",
                      description: "Name",
                      required: true
                    }
                  ]
                }
              ]
            }
          }
        end
      end

      test "should return prompts list when arguments do not exist" do
        @schema_class = Class.new(ActiveMcp::Schema::Base) do
          prompt NoArgumentPrompt
        end
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {method: Method::PROMPTS_LIST}

          assert_response :success

          json = JSON.parse(response.body, symbolize_names: true)
          assert_equal json, {
            result: {
              prompts: [
                {
                  name: "dummy",
                  description: "This is a dummy",
                  arguments: []
                }
              ]
            }
          }
        end
      end
    end
  end
end
