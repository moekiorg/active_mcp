require "test_helper"

module ActiveMcp
  class ResourceTemplatesListTest < ActionController::TestCase
    setup do
      @routes = ActiveMcp::Engine.routes
      @controller = ActiveMcp::BaseController.new

      @test_resource_template_class = Class.new do
        def name
          "test"
        end

        def uri_template
          "data://app/{name}.json"
        end
        
        def mime_type
          "application/json"
        end
        
        def description
          "Test resource for controller testing"
        end
      end
    end

    test "should return resource templates list" do
      @controller.stub(:resource_templates_list, [@test_resource_template_class.new]) do
        post "index", params: {method: Method::RESOURCES_TEMPLATES_LIST}

        assert_response :success

        json = JSON.parse(response.body)
        assert_not_nil json["result"]

        resource_templates = json["result"]
        test_resource = resource_templates.find { |t| t["name"] == "test" }
        assert_not_nil test_resource
        assert_equal "Test resource for controller testing", test_resource["description"]
        assert_not_nil test_resource["uriTemplate"]
        assert_not_nil test_resource["mimeType"]
      end
    end

    test "should return resource templates list when jsonrpc" do
      @controller.stub(:resource_templates_list, [@test_resource_template_class.new]) do
        post "index", params: {jsonrpc: "2.0", method: Method::RESOURCES_TEMPLATES_LIST}

        assert_response :success

        json = JSON.parse(response.body)
        assert_not_nil json["result"]

        resource_templates = json["result"]["resourceTemplates"]
        test_resource = resource_templates.find { |t| t["name"] == "test" }
        assert_not_nil test_resource
        assert_equal "Test resource for controller testing", test_resource["description"]
        assert_not_nil test_resource["uriTemplate"]
        assert_not_nil test_resource["mimeType"]
      end
    end
  end
end
