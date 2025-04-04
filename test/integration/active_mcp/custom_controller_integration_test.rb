require "test_helper"

module ActiveMcp
  class CustomControllerIntegrationTest < ActionDispatch::IntegrationTest
    setup do
      @routes = Rails.application.routes
      
      Tool.registered_tools = []
      
      @test_tool_class = Class.new(ActiveMcp::Tool) do
        description "Custom controller test tool"
        
        property :name, :string, required: true, description: "Name parameter"
        property :value, :integer, required: false, description: "Value parameter"
        
        def call(name:, value: nil, auth_info: nil, **args)
          if auth_info
            "Authenticated tool executed with name: #{name}, value: #{value}, auth: #{auth_info[:user][:name]}"
          else
            "Tool executed with name: #{name}, value: #{value}"
          end
        end
      end
      
      @test_tool_class.instance_variable_set(:@tool_name, "custom_test_tool")
      
      Tool.registered_tools << @test_tool_class
      
      @valid_auth_header = "Bearer valid-token"
      @invalid_auth_header = "Bearer invalid-token"
    end
    
    
    def test_custom_controller_placeholder
      skip "Custom controller tests need proper setup in the dummy app"
    end
  end
end
