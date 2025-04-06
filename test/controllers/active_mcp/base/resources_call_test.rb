require "test_helper"

module ActiveMcp
  class ResourcesListTest < ActionController::TestCase
    setup do
      @routes = ActiveMcp::Engine.routes
      @controller = ActiveMcp::BaseController.new

      ActiveMcp::Resource.registered_resources = []

      @test_resource_class = Class.new(ActiveMcp::Resource) do
        uri "data://app/data.json"
        mime_type "application/json"
        description "Test resource for controller testing"

        def text(auth_info: nil)
          "Test resource"
        end
      end

      Object.const_set(:TestResource, @test_resource_class)

      ActiveMcp::Resource.registered_resources << @test_resource_class unless ActiveMcp::Resource.registered_resources.include?(@test_resource_class)
    end

    test "should get resources" do
      post "index", params: {method: "resources/read", uri: "data://app/data.json"}

      assert_response :success

      json = JSON.parse(response.body)
      assert json["contents"][0]["text"], "Test resource"
      assert json["contents"][0]["mimeType"], "application/json"
      assert_nil json["contents"][0]["blob"]
    end
  end
end
