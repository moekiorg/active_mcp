require "test_helper"

module ActiveMcp
  class ResourceTest < ActiveSupport::TestCase
    test "should register resource with name and description" do
      resource_class = Class.new(ActiveMcp::Resource) do
        uri "file://app/image.png"
        mime_type "image/png"
        description "Test resource description"
      end

      assert_equal "Test resource description", resource_class._description
      assert_equal "file://app/image.png", resource_class._uri
      assert_equal "image/png", resource_class._mime_type
    end

    test "should add inherited resource classes to registered resources" do
      initial_count = ActiveMcp::Resource.registered_resources.count

      resource_class = Class.new(ActiveMcp::Resource)

      assert_equal initial_count + 1, ActiveMcp::Resource.registered_resources.count
      assert_includes ActiveMcp::Resource.registered_resources, resource_class
    end

    test "should receive auth info in call method" do
      resource_class = Class.new(ActiveMcp::Resource) do
        uri "files://app/image.png"
        mime_type "image/png"

        def call(param:, auth_info: nil, **args)
          auth_type = auth_info&.dig(:type)
          auth_token = auth_info&.dig(:token)

          "Auth type: #{auth_type}, token: #{auth_token}, param: #{param}"
        end
      end

      resource = resource_class.new

      result = resource.call(param: "test")
      assert_equal "Auth type: , token: , param: test", result

      result = resource.call(
        param: "test",
        auth_info: {
          type: :bearer,
          token: "test-token",
          header: "Bearer test-token"
        }
      )
      assert_equal "Auth type: bearer, token: test-token, param: test", result

      result = resource.call(
        param: "test",
        auth_info: {
          type: :basic,
          token: "dXNlcjpwYXNz", # user:pass in base64
          header: "Basic dXNlcjpwYXNz"
        }
      )
      assert_equal "Auth type: basic, token: dXNlcjpwYXNz, param: test", result
    end
  end
end
