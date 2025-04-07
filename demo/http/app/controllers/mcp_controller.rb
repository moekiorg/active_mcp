class McpController < ActiveMcp::BaseController

  private

  def resources_list
    [
      UserResource.new(name: "UserA"),
      UserResource.new(name: "UserB"),
      ImageResource.new
    ]
  end

  def resource_templates_list
    [
      PostResourceTemplate.new
    ]
  end
end
