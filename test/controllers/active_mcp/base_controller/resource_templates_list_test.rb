require "test_helper"

module ActiveMcp
  class BaseController
    class ResourceTemplatesListTest < ActionController::TestCase
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

      test "should return resource templates list" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {method: Method::RESOURCES_TEMPLATES_LIST}

          assert_response :success

          json = JSON.parse(response.body)
          assert_not_nil json["result"]

          resource_templates = json["result"]["resourceTemplates"]
          test_resource = resource_templates.find { |t| t["name"] == "dummy" }
          assert_not_nil test_resource
          assert_not_nil test_resource["uriTemplate"]
          assert_not_nil test_resource["mimeType"]
        end
      end

      test "should return resource templates list when jsonrpc" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {jsonrpc: "2.0", method: Method::RESOURCES_TEMPLATES_LIST}

          assert_response :success

          json = JSON.parse(response.body)
          assert_not_nil json["result"]

          resource_templates = json["result"]["resourceTemplates"]
          test_resource = resource_templates.find { |t| t["name"] == "dummy" }
          assert_not_nil test_resource
          assert_not_nil test_resource["uriTemplate"]
          assert_not_nil test_resource["mimeType"]
        end
      end
    end
  end
end
