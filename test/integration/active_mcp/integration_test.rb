require "test_helper"

module ActiveMcp
  class IntegrationTest < ActionDispatch::IntegrationTest
    setup do
      @routes = Engine.routes
      
      Tool.registered_tools = []
      
      @test_tool_class = Class.new(ActiveMcp::Tool) do
        description "Integration test tool"
        
        property :name, :string, required: true, description: "Name parameter"
        property :value, :integer, required: false, description: "Value parameter"
        
        def call(name:, value: nil, auth_info: nil, **args)
          "TestTool executed with name: #{name}, value: #{value}"
        end
      end
      
      @test_tool_class.instance_variable_set(:@tool_name, "test_integration_tool")
      
      Tool.registered_tools << @test_tool_class
      
      @auth_header = "Bearer valid-token"
    end
    
    test "should list available tools" do
      post "/", params: { 
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 1,
        method: Method::TOOLS_LIST
      }, as: :json
      
      assert_response :success
      
      json_response = JSON.parse(response.body)
      assert_not_nil json_response["result"]
      
      tools = json_response["result"]
      tool_names = tools.map { |tool| tool["name"] }
      assert_includes tool_names, "test_integration_tool"
    end
    
    test "should call a tool successfully" do
      post "/", params: { 
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 2,
        method: Method::TOOLS_CALL,
        params: {
          name: "test_integration_tool",
          arguments: { name: "Test", value: 42 }
        }
      }, as: :json
      
      assert_response :success
      
      json_response = JSON.parse(response.body)
      assert_not_nil json_response["result"]
      assert_equal "TestTool executed with name: Test, value: 42", json_response["result"]
    end
    
    test "should handle validation errors" do
      post "/", params: { 
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 3,
        method: Method::TOOLS_CALL,
        params: {
          name: "test_integration_tool",
          arguments: { value: 42 }
        }
      }, as: :json
      
      assert_response :success
      
      json_response = JSON.parse(response.body)
      assert_not_nil json_response["error"]
      assert_match(/name/, json_response["error"])
    end
    
    test "should handle tool not found error" do
      post "/", params: { 
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 4,
        method: Method::TOOLS_CALL,
        params: {
          name: "nonexistent_tool",
          arguments: {}
        }
      }, as: :json
      
      assert_response :not_found
      
      json_response = JSON.parse(response.body)
      assert_not_nil json_response["error"]
      assert_match(/nonexistent_tool/, json_response["error"])
    end
    
    test "should handle invalid method" do
      post "/", params: { 
        jsonrpc: ActiveMcp::JSON_RPC_VERSION,
        id: 6,
        method: "invalid/method"
      }, as: :json
      
      assert_response :not_found
      
      json_response = JSON.parse(response.body)
      assert_not_nil json_response["error"]
      assert_match(/invalid\/method/, json_response["error"])
    end
    
    test "should check health endpoint" do
      get "/health", as: :json
      
      assert_response :success
      assert_equal "OK", response.body
    end
  end
end
