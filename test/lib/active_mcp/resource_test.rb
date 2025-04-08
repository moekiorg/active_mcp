require "test_helper"

module ActiveMcp
  class ToolTest < ActiveSupport::TestCase
    test "should parse content" do
      resource_class = Class.new(ActiveMcp::Resource::Base) do
        def text
          "Test"
        end
      end

      assert_equal "Test", resource_class.new.content

      resource_class = Class.new(ActiveMcp::Resource::Base) do
        def text
          {foo: "bar"}
        end
      end

      assert_equal '{"foo":"bar"}', resource_class.new.content

      resource_class = Class.new(ActiveMcp::Resource::Base) do
        def text
          String
        end
      end

      assert_match "String", resource_class.new.content
    end
  end
end
