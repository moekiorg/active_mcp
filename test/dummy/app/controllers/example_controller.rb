class ExampleController < ActiveMcp::BaseController
  def schema
    ExampleSchema.new(context:)
  end
end
