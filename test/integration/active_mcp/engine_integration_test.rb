require "test_helper"

module ActiveMcp
  class EngineIntegrationTest < ActionController::TestCase
    setup do
      @routes = Engine.routes
      @controller = ActiveMcp::BaseController.new
      
      Tool.registered_tools = []
      
      @test_tool_class = Class.new(ActiveMcp::Tool) do
        description "Engine integration test tool"
        
        property :name, :string, required: true, description: "Name parameter"
        property :value, :integer, required: false, description: "Value parameter"
        
        def call(name:, value: nil, auth_info: nil, **args)
          "EngineTool executed with name: #{name}, value: #{value}"
        end
      end
      
      @test_tool_class.instance_variable_set(:@tool_name, "test")
      
      Object.const_set(:TestTool, @test_tool_class) unless Object.const_defined?(:TestTool)
      
      Tool.registered_tools << @test_tool_class unless Tool.registered_tools.include?(@test_tool_class)
    end
    test "should initialize server" do
      post :index, params: { 
        method: ActiveMcp::Method::INITIALIZE,
        params: {
          protocolVersion: ActiveMcp::PROTOCOL_VERSION
        }.to_json
      }
      
      assert_response :success
      
      json_response = JSON.parse(response.body)
      assert_not_nil json_response["result"]
      assert_equal ActiveMcp::PROTOCOL_VERSION, json_response["result"]["protocolVersion"]
    end
    
    test "should list available tools" do
      post :index, params: { 
        method: ActiveMcp::Method::TOOLS_LIST
      }
      
      assert_response :success
      
      json_response = JSON.parse(response.body)
      assert_not_nil json_response["result"]
      
      tools = json_response["result"]
      tool_names = tools.map { |tool| tool["name"] }
      assert_includes tool_names, "test"
    end
    
    test "should call a tool successfully" do
      post :index, params: { 
        method: ActiveMcp::Method::TOOLS_CALL,
        name: "test",
        arguments: { name: "Test", value: 42 }.to_json
      }
      
      assert_response :success
      
      json_response = JSON.parse(response.body)
      assert_not_nil json_response["result"]
      assert_match(/EngineTool executed with name: Test/, json_response["result"].to_s)
    end
    
    test "should handle validation errors" do
      post :index, params: { 
        method: ActiveMcp::Method::TOOLS_CALL,
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
        method: ActiveMcp::Method::TOOLS_CALL,
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
    
    test "should check health endpoint" do
      skip "Health endpoint is tested in HealthControllerTest"
    end
  end
end
