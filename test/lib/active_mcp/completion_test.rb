require "test_helper"
require "net/http"

module ActiveMcp
  class CompletionTest < ActiveSupport::TestCase
    test "should initialize with base uri when the primitive is resource" do
      completion = ActiveMcp::Completion.new
      template = Class.new(ActiveMcp::Resource::Base) do
        class << self
          def uri_template
            "data://app/users/{name}.json"
          end
        end

        argument :name, complete: ->(value, _) do
          ["Foo", "Bar"].filter { _1.match(value) }
        end
      end
      assert_equal completion.complete(
        params: {
          ref: {
            type: "ref/resource",
            uri: "data://app/users/{name}.json"
          },
          argument: {
            name: "name",
            value: "F"
          }
        },
        refs: [template]
      ), {values: ["Foo"], total: 1}
    end

    test "should initialize with base uri when the primitive is prompt" do
      completion = ActiveMcp::Completion.new
      prompt_class = Class.new(ActiveMcp::Prompt::Base) do
        def prompt_name
          "hello"
        end

        argument :name, required: true, description: "Name", complete: ->(value, _) do
          ["Foo", "Bar"].filter { _1.match?(value) }
        end
      end
      assert_equal completion.complete(
        params: {
          ref: {
            type: "ref/prompt",
            name: "hello"
          },
          argument: {
            name: "name",
            value: "F"
          }
        },
        refs: [prompt_class.new]
      ), {values: ["Foo"], total: 1}
    end
  end
end
