require "test_helper"

module ActiveMcp
  class ResourcesListTest < ActionController::TestCase
    setup do
      @routes = ActiveMcp::Engine.routes
      @controller = ActiveMcp::Controller::Base.new

      @test_resource_class = Class.new do
        class << self 
          def mime_type
            "application/json"
          end
        end

        def name
          "test"
        end

        def uri
          "data://app/data.json"
        end
        
        def description
          "Test resource for controller testing"
        end

        def text
          "Test resource"
        end
      end

      Object.const_set(:TestResource, @test_resource_class)

      @schema_class = Class.new(ActiveMcp::Schema::Base) do
        resource TestResource.new
      end
    end

    test "should return resources list" do
      @controller.stub(:schema, @schema_class.new) do
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
    end

    test "should return resources list when jsonrpc" do
      @controller.stub(:schema, @schema_class.new) do
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
end
