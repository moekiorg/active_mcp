require "test_helper"

module ActiveMcp
  class BaseControllerTest < ActionController::TestCase
    setup do
      @routes = ActiveMcp::Engine.routes
      @controller = ActiveMcp::BaseController.new
    end

    test "should response to initialize" do
      post "index", params: {method: Method::INITIALIZE}
      assert_response :success

      post "index", params: {method: Method::INITIALIZE, jsonrpc: "2.0"}
      assert_response :success
    end

    test "should response to initialized" do
      post "index", params: {method: Method::INITIALIZED}
      assert_response :success
      post "index", params: {method: Method::INITIALIZED, jsonrpc: "2.0"}
      assert_response :success
    end

    test "should response to cancelled" do
      post "index", params: {method: Method::CANCELLED}
      assert_response :success
      post "index", params: {method: Method::CANCELLED, jsonrpc: "2.0"}
      assert_response :success
    end
  end
end
