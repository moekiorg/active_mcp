class CustomController < ActiveMcp::BaseController
  before_action :authenticate_request, only: [:index]

  private

  def authenticate_request
    authenticate

    if @auth_info&.dig(:type) == :bearer
      token = @auth_info[:token]
      user = authenticate_with_token(token)

      unless user
        render json: {error: "Invalid or expired token"}, status: 403
        return false
      end

      @auth_info[:user] = user

      @auth_info[:role] = user[:role]
      @auth_info[:permissions] = user[:permissions]
    elsif @auth_info&.dig(:type) == :basic
      credentials = Base64.decode64(@auth_info[:token]).split(":")
      username = credentials[0]
      password = credentials[1]

      user = authenticate_with_credentials(username, password)

      unless user
        render json: {error: "Invalid username or password"}, status: 403
        return false
      end

      @auth_info[:user] = user
      @auth_info[:role] = user[:role]
      @auth_info[:permissions] = user[:permissions]
    else
      render json: {error: "Authentication required"}, status: 403
      return false
    end

    true
  end

  def authenticate_with_token(token)
    if token == "valid-token"
      {id: 1, name: "Admin User", role: :admin, permissions: [:read, :write, :delete]}
    elsif token == "user-token"
      {id: 2, name: "Regular User", role: :user, permissions: [:read]}
    end
  end

  def authenticate_with_credentials(username, password)
    if username == "admin" && password == "admin123"
      {id: 1, name: "Admin User", role: :admin, permissions: [:read, :write, :delete]}
    elsif username == "user" && password == "pass"
      {id: 2, name: "Regular User", role: :user, permissions: [:read]}
    end
  end
end
