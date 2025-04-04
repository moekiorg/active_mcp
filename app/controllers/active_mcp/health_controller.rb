module ActiveMcp
  class HealthController < ActionController::Base
    def index
      render plain: "OK"
    end
  end
end
