class CustomController < ActiveMcp::Controller::Base
  before_action :authenticate_user, only: [:index]

  private

  def resources_list
    [
      UserResource.new(name: "UserA"),
      UserResource.new(name: "UserB"),
      ImageResource.new
    ]
  end

  def authenticate_user
    authenticate

    if @auth_info.present?
      if @auth_info[:type] == :bearer
        token = @auth_info[:token]

        if token == "valid-token"
          @auth_info[:user] = {
            id: 1,
            name: "Test User",
            role: "admin"
          }
        else
          render json: {error: "Invalid Token"}, status: 403
          return false
        end
      elsif @auth_info[:type] == :basic
        auth_str = Base64.decode64(@auth_info[:token])
        username, password = auth_str.split(":")

        if username == "user" && password == "pass"
          @auth_info[:user] = {
            id: 2,
            name: "Kevin",
            role: "user"
          }
        else
          render json: {error: "Invalid User"}, status: 403
          return false
        end
      end
    end

    if !@auth_info.present?
      render json: {error: "Authorization Required"}, status: 403
      return false
    end

    true
  end
end
