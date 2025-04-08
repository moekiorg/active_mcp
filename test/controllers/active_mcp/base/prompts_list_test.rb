require "test_helper"

module ActiveMcp
  class PromptsListTest < ActionController::TestCase
    setup do
      @routes = ActiveMcp::Engine.routes
      @controller = ActiveMcp::BaseController.new

      @schema_class = Class.new(ActiveMcp::Schema::Base) do
        prompt DummyPrompt
      end
    end

    test "should return resources list" do
      @controller.stub(:schema, @schema_class.new) do
        post "index", params: {method: Method::PROMPTS_LIST}

        assert_response :success

        json = JSON.parse(response.body, symbolize_names: true)
        assert_equal json, {
          result: [
            {
              name: "dummy",
              description: "This is a dummy",
              arguments: [
                {
                  name: "name",
                  description: "Name",
                  required: true
                }
              ]
            }
          ]
        }
      end
    end

    test "should return resources list when jsonrpc" do
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
  end
end
