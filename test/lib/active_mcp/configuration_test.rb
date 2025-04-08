require "test_helper"

module ActiveMcp
  class ConfigurationTest < ActiveSupport::TestCase
    test "should set up config" do
      ActiveMcp.configure do |config|
        config.server_name = "Test Server"
      end

      assert ActiveMcp.config.server_name, "Test Server"
    end
  end
end
