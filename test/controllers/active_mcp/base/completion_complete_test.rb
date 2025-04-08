require "test_helper"

module ActiveMcp
  class CompletionCompleteTest < ActionController::TestCase
    setup do
      @routes = ActiveMcp::Engine.routes
      @controller = ActiveMcp::Controller::Base.new

      @test_resource_class = Class.new(ActiveMcp::Resource::Base) do
        class << self
          def name
            "users"
          end

          def uri_template
            "data://app/users/{name}.json"
          end
          
          def mime_type
            "application/json"
          end
          
          def description
            "Test resource for controller testing"
          end
        end

        argument :name, ->(value) do
          ["Foo", "Bar"].filter { _1.match(value) }
        end
      end

      Object.const_set(:TestResource, @test_resource_class)

      @schema_class = Class.new(ActiveMcp::Schema::Base) do
        resource TestResource.new
      end
    end

    test "should return completion list" do
      @controller.stub(:schema, @schema_class.new) do
        post "index", params: {
          method: Method::COMPLETION_COMPLETE,
          params: {
            ref: {
              type: "ref/resource",
              uri: "data://app/users/{name}.json"
            },
            argument: {
              name: "name",
              value: "F"
            },
          }
        }

        assert_response :success

        json = JSON.parse(response.body)
        assert_equal json["result"], {
          "values" => ["Foo"],
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
              uri: "data://app/users/{name}.json"
            },
            argument: {
              name: "name",
              value: "F"
            },
          }
        }

        assert_response :success

        json = JSON.parse(response.body)
        assert_equal json["result"]["completion"], {
          "values" => ["Foo"],
          "total" => 1
        }
      end
    end
  end
end
