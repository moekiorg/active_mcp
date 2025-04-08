require "test_helper"

module ActiveMcp
  class BaseController
    class CompletionCompleteTest < ActionController::TestCase
      setup do
        @routes = ActiveMcp::Engine.routes
        @controller = ActiveMcp::BaseController.new
        @schema_class = Class.new(ActiveMcp::Schema::Base) do
          resource DummyResource.new(name: "UserA")
        end
      end

      test "should return completion list" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {
            method: Method::COMPLETION_COMPLETE,
            params: {
              ref: {
                type: "ref/resource",
                uri: "data://app/users/{name}"
              },
              argument: {
                name: "name",
                value: "A"
              }
            }
          }

          assert_response :success

          json = JSON.parse(response.body)
          assert_equal json["result"]["completion"], {
            "values" => ["UserA"],
            "total" => 1
          }
        end
      end

      test "should return completion list when jsonrpc" do
        @controller.stub(:schema, @schema_class.new) do
          post "index", params: {
            jsonrpc: "2.0",
            method: Method::COMPLETION_COMPLETE,
            params: {
              ref: {
                type: "ref/resource",
                uri: "data://app/users/{name}"
              },
              argument: {
                name: "name",
                value: "A"
              }
            }
          }

          assert_response :success

          json = JSON.parse(response.body)
          assert_equal json["result"]["completion"], {
            "values" => ["UserA"],
            "total" => 1
          }
        end
      end
    end
  end
end
