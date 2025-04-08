class McpController < ActiveMcp::BaseController
  def schema
    DemoSchema.new(context:)
  end
end
