# frozen_string_literal: true

module ActiveMcp
  class BaseController < ActionController::Base
    protect_from_forgery with: :null_session
    skip_before_action :verify_authenticity_token
    before_action :authenticate, only: [:index]

    def index
      case params[:method]
      when Method::INITIALIZE
        result = Response::Initialize.call(id: params[:id])
      when Method::INITIALIZED
        result = Response::Initialized.call
      when Method::CANCELLED
        result = Response::Cancelled.call
      when Method::TOOLS_LIST
        tools = Response::Tools.to_hash(auth_info: @auth_info)
        if params[:jsonrpc]
          result = Response::ToolsList::Jsonrpc.call(id: params[:id], tools:)
        else
          result = Response::ToolsList::Json.call(tools:)
        end
      when Method::TOOLS_CALL
        if params[:jsonrpc]
          result = Response::ToolsCall::Jsonrpc.call(id: params[:id], params:, auth_info: @auth_info)
        else
          result = Response::ToolsCall::Json.call(params:, auth_info: @auth_info)
        end
      else
        result = Response::NoMethod.call
      end

      render json: result[:body], status: result[:status]
    end

    private

    def authenticate
      auth_header = request.headers["Authorization"]
      if auth_header.present?
        @auth_info = {
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
  end
end
