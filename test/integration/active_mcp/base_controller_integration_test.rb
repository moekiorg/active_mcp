require "test_helper"

module ActiveMcp
  class BaseControllerIntegrationTest < ActionController::TestCase
    setup do
      @routes = ActiveMcp::Engine.routes
      @controller = ActiveMcp::BaseController.new
      
      Tool.registered_tools = []
      
      @test_tool_class = Class.new(ActiveMcp::Tool) do
        description "Base controller integration test tool"
        
        property :name, :string, required: true, description: "Name parameter"
        property :value, :integer, required: false, description: "Value parameter"
        
        def call(name:, value: nil, auth_info: nil, **args)
          "BaseControllerTool executed with name: #{name}, value: #{value}"
        end
      end
      
      Object.const_set(:TestTool, @test_tool_class)
      
      Tool.registered_tools << @test_tool_class
    end
    
    test "should list available tools" do
      post :index, params: { method: Method::TOOLS_LIST }
      
      assert_response :success
      
      json_response = JSON.parse(response.body)
      assert_not_nil json_response["result"]
      
      tools = json_response["result"]
      tool_names = tools.map { |tool| tool["name"] }
      assert_includes tool_names, "test"
    end
    
    test "should call a tool successfully" do
      post :index, params: { 
        method: Method::TOOLS_CALL,
        name: "test",
        arguments: { name: "Test", value: 42 }.to_json
      }
      
      assert_response :success
      
      json_response = JSON.parse(response.body)
      assert_not_nil json_response["result"]
      assert_equal "BaseControllerTool executed with name: Test, value: 42", json_response["result"]
    end
    
    test "should handle validation errors" do
      post :index, params: { 
        method: Method::TOOLS_CALL,
        name: "test",
        arguments: { value: 42 }.to_json
      }
      
      assert_response :success
      
      json_response = JSON.parse(response.body)
      assert_not_nil json_response["result"]
      assert_match(/name/, json_response["result"])
    end
    
    test "should handle tool not found error" do
      post :index, params: { 
        method: Method::TOOLS_CALL,
        name: "nonexistent_tool",
        arguments: {}.to_json
      }
      
      assert_response :not_found
      
      json_response = JSON.parse(response.body)
      assert_not_nil json_response["error"]
      assert_match(/Tool not found/, json_response["error"])
    end
    
    test "should handle invalid method" do
      post :index, params: { 
        method: "invalid/method"
      }
      
      assert_response :not_found
      
      json_response = JSON.parse(response.body)
      assert_not_nil json_response["error"]
      assert_match(/Method not found/, json_response["error"])
    end
  end
end
