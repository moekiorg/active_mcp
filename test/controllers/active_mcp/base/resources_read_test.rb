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

    test "should get resources" do
      @controller.stub(:schema, @schema_class.new) do
        post "index", params: {method: "resources/read", uri: "data://app/data.json"}

        assert_response :success

        json = JSON.parse(response.body)
        assert json["contents"][0]["text"], "Test resource"
        assert json["contents"][0]["mimeType"], "application/json"
        assert_nil json["contents"][0]["blob"]
      end
    end
  end
end
