require "test_helper"
require "net/http"

module ActiveMcp
  class ServerTest < ActiveSupport::TestCase
    setup do
      @uri = "http://localhost:3000/mcp"
      @server = ActiveMcp::Server.new(uri: @uri)
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
  end
end
