class McpController < ActiveMcp::Controller::Base
  def schema
    DemoSchema.new(context:)
  end
end
