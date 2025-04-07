class ExampleController < ActiveMcp::Controller::Base
  def schema
    ExampleSchema.new(context:)
  end
end
