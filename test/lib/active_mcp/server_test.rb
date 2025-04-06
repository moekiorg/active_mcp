require "test_helper"
require "net/http"

module ActiveMcp
  class ServerTest < ActiveSupport::TestCase
    setup do
      @uri = "http://localhost:3000/mcp"
      @server = ActiveMcp::Server.new(uri: @uri)

      @test_tool_class = Class.new(ActiveMcp::Tool) do
        description "Mock test tool for testing"

        property :name, :string, required: true, description: "Name parameter"
        property :value, :integer, required: false, description: "Value parameter"

        def call(name:, value: nil)
          "MockTestTool executed with name: #{name}, value: #{value}"
        end
      end
    end

    test "should initialize with base uri" do
      assert_equal @uri, @server.uri
    end

    test "should initialize with options" do
      server = ActiveMcp::Server.new(uri: @uri, name: "Test Server")
      assert_equal "Test Server", server.name
    end

    test "should initialize protocol handler" do
      assert @server.protocol_handler.initialized == false
    end

    test "should have a tool manager" do
      assert_instance_of ActiveMcp::Server::ToolManager, @server.tool_manager
    end

    test "should have a protocol handler" do
      assert_instance_of ActiveMcp::Server::ProtocolHandler, @server.protocol_handler
    end

    test "should report error for nonexistent tool" do
      result = @server.tool_manager.call_tool("nonexistent_tool", {})

      assert result[:isError]
      assert_equal "Tool not found: nonexistent_tool", result[:content][0][:text]
    end

    test "should register tools" do
      @server.tool_manager.instance_variable_set(:@tools, {
        "test_tool" => {
          name: "test_tool",
          description: "Test tool description",
          inputSchema: {}
        }
      })

      assert_includes @server.tools.keys, "test_tool"
      assert_equal "Test tool description", @server.tools["test_tool"][:description]
    end
  end
end
