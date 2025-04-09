require "test_helper"

module ActiveMcp
  class BaseController
    class ResourcesListTest < ActionController::TestCase
      setup do
        @routes = ActiveMcp::Engine.routes
        @controller = ActiveMcp::BaseController.new

        @schema_class = Class.new(ActiveMcp::Schema::Base) do
          def resources
            [
              DummyResource.new(name: "UserA")
            ]
          end
        end
      end

      test "should get resources" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {method: "resources/read", uri: "data://app/users/UserA"}

          assert_response :success

          json = JSON.parse(response.body)
          assert json["result"]["contents"][0]["text"], "Test resource"
          assert json["result"]["contents"][0]["mimeType"], "application/json[:result]"
          assert_nil json["result"]["contents"][0]["blob"]
        end
      end

      test "should get resources when jsonrpc" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {method: "resources/read", jsonrpc: "2.0", params: {uri: "data://app/users/UserA"}}

          assert_response :success

          json = JSON.parse(response.body)
          assert json["result"]["contents"][0]["text"], "Test resource"
          assert json["result"]["contents"][0]["mimeType"], "application/json"
          assert_nil json["result"]["contents"][0]["blob"]
        end
      end
    end
  end
end
