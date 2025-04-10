require "test_helper"

module ActiveMcp
  class BaseController
    class ResourcesListTest < ActionController::TestCase
      setup do
        @routes = ActiveMcp::Engine.routes
        @controller = ActiveMcp::BaseController.new

        @schema_class = Class.new(ActiveMcp::Schema::Base) do
          resource DummyResource
        end
      end

      test "should return resources list" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {method: "resources/list"}

          assert_response :success

          json = JSON.parse(response.body)
          assert_not_nil json["result"]

          resources = json["result"]["resources"]
          test_resource = resources.find { |t| t["name"] == "UserA" }
          assert_not_nil test_resource
          assert_equal "This is a dummy", test_resource["description"]
          assert_not_nil test_resource["uri"]
          assert_not_nil test_resource["mimeType"]
        end
      end

      test "should return resources list when jsonrpc" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {jsonrpc: "2.0", method: "resources/list"}

          assert_response :success

          json = JSON.parse(response.body)
          assert_not_nil json["result"]

          resources = json["result"]["resources"]
          test_resource = resources.find { |t| t["name"] == "UserA" }
          assert_not_nil test_resource
          assert_equal "This is a dummy", test_resource["description"]
          assert_not_nil test_resource["uri"]
          assert_not_nil test_resource["mimeType"]
        end
      end
    end
  end
end
