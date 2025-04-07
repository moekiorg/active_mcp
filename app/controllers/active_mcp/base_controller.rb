# frozen_string_literal: true

module ActiveMcp
  class BaseController < ActionController::Base
    include RequestHandlable
    include ResourceReadable
    include ToolExecutable
  end
end
