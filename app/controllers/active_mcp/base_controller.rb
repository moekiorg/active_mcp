# frozen_string_literal: true

module ActiveMcp
  class BaseController < ActionController::Base
    include RequestHandler
  end
end
