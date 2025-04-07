module ActiveMcp
  module Authenticatable
    extend ActiveSupport::Concern

    private

    def authenticate
      auth_header = request.headers["Authorization"]
      if auth_header.present?
        @context ||= {}
        @context[:auth_info] = {
          header: auth_header,
          type: if auth_header.start_with?("Bearer ")
                  :bearer
                elsif auth_header.start_with?("Basic ")
                  :basic
                else
                  :unknown
                end,
          token: auth_header.split(" ").last
        }
      end
    end

    def context
      @context
    end
  end
end
