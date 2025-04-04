require "test_helper"

module ActiveMcp
  class McpIntegrationTest < ActionDispatch::IntegrationTest
    setup do
      @routes = Rails.application.routes
      
      Tool.registered_tools = []
      
      @test_tool_class = Class.new(ActiveMcp::Tool) do
        description "MCP integration test tool"
        
        property :name, :string, required: true, description: "Name parameter"
        property :value, :integer, required: false, description: "Value parameter"
        
        def call(name:, value: nil, auth_info: nil, **args)
          "McpTool executed with name: #{name}, value: #{value}"
        end
      end
      
      @test_tool_class.instance_variable_set(:@tool_name, "mcp_test_tool")
      
      Tool.registered_tools << @test_tool_class
    end
    
    test "should list available tools" do
      post "/mcp", params: { 
        jsonrpc: "2.0",
        id: 1,
        method: Method::TOOLS_LIST
      }, as: :json
      
      assert_response :success
      
      json_response = JSON.parse(response.body)
      assert_not_nil json_response["result"]
      
      tools = json_response["result"]
      tool_names = tools.map { |tool| tool["name"] }
      assert_includes tool_names, "mcp_test_tool"
    end
    
    test "should call a tool successfully" do
      post "/mcp", params: { 
        method: Method::TOOLS_CALL,
        name: "mcp_test_tool",
        arguments: { name: "Test", value: 42 }.to_json
      }, as: :json
      
      assert_response :success
      
      json_response = JSON.parse(response.body)
      assert_not_nil json_response["result"]
      assert_equal "McpTool executed with name: Test, value: 42", json_response["result"]
    end
    
    test "should handle validation errors" do
      post "/mcp", params: { 
        method: Method::TOOLS_CALL,
        name: "mcp_test_tool",
        arguments: { value: 42 }.to_json
      }, as: :json
      
      assert_response :success
      
      json_response = JSON.parse(response.body)
      assert_match(/name/, json_response["result"])
    end
    
    test "should handle tool not found error" do
      post "/mcp", params: { 
        method: Method::TOOLS_CALL,
        name: "nonexistent_tool",
        arguments: {}.to_json
      }, as: :json
      
      assert_response :not_found
      
      json_response = JSON.parse(response.body)
      assert_match(/Tool not found/, json_response["error"])
    end
    
    test "should handle invalid method" do
      post "/mcp", params: { 
        method: "invalid/method"
      }, as: :json
      
      assert_response :not_found
      
      json_response = JSON.parse(response.body)
      assert_match(/Method not found/, json_response["error"])
    end
    
    test "should check health endpoint" do
      get "/mcp/health", as: :json
      
      assert_response :success
      assert_equal "OK", response.body
    end
  end
end
