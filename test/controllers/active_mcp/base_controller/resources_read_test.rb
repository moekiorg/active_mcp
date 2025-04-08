require "test_helper"

module ActiveMcp
  class BaseController
    class ResourcesListTest < ActionController::TestCase
      setup do
        @routes = ActiveMcp::Engine.routes
        @controller = ActiveMcp::BaseController.new

        @schema_class = Class.new(ActiveMcp::Schema::Base) do
          resource DummyResource.new(name: "UserA")
        end
      end

      test "should get resources" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {method: "resources/read", uri: "data://app/users/UserA"}

          assert_response :success

          json = JSON.parse(response.body)
          assert json["contents"][0]["text"], "Test resource"
          assert json["contents"][0]["mimeType"], "application/json"
          assert_nil json["contents"][0]["blob"]
        end
      end
    end
  end
end
