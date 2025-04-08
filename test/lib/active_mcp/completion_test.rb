require "test_helper"
require "net/http"

module ActiveMcp
  class CompletionTest < ActiveSupport::TestCase
    setup do
      @completion = ActiveMcp::Completion.new
      @template = Class.new(ActiveMcp::Resource::Base) do
        class << self
          def uri_template
            "data://app/users/{name}.json"
          end
        end

        argument :name, ->(value) do
          ["Foo", "Bar"].filter { _1.match(value) }
        end
      end
    end

    test "should initialize with base uri" do
      assert_equal @completion.complete(
        params: {
          ref: {
            type: "ref/resource",
            uri: "data://app/users/{name}.json"
          },
          argument: {
            name: "name",
            value: "F"
          },
        },
        refs: [@template]
      ), { values: ["Foo"], total: 1 }
    end
  end
end
