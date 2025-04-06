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

    test "should return resources list" do
      post "index", params: {method: "resources/list"}

      assert_response :success

      json = JSON.parse(response.body)
      assert_not_nil json["result"]

      resources = json["result"]
      test_resource = resources.find { |t| t["name"] == "test" }
      assert_not_nil test_resource
      assert_equal "Test resource for controller testing", test_resource["description"]
      assert_not_nil test_resource["uri"]
      assert_not_nil test_resource["mimeType"]
    end

    test "should return resources list when jsonrpc" do
      post "index", params: {jsonrpc: "2.0", method: "resources/list"}

      assert_response :success

      json = JSON.parse(response.body)
      assert_not_nil json["result"]

      resources = json["result"]["resources"]
      test_resource = resources.find { |t| t["name"] == "test" }
      assert_not_nil test_resource
      assert_equal "Test resource for controller testing", test_resource["description"]
      assert_not_nil test_resource["uri"]
      assert_not_nil test_resource["mimeType"]
    end
  end
end
