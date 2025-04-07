require "test_helper"

module ActiveMcp
  class ResourcesListTest < ActionController::TestCase
    setup do
      @routes = ActiveMcp::Engine.routes
      @controller = ActiveMcp::BaseController.new

      @test_resource_class = Class.new do
        def name
          "test"
        end

        def uri
          "data://app/data.json"
        end

        def mime_type
          "application/json"
        end
        
        def description
          "Test resource for controller testing"
        end

        def text
          "Test resource"
        end
      end
    end

    test "should get resources" do
      @controller.stub(:resources_list, [@test_resource_class.new]) do
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
