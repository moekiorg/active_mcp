require "test_helper"

module ActiveMcp
  class AuthorizationTest < ActionController::TestCase
    setup do
      @routes = ActiveMcp::Engine.routes
      @controller = ActiveMcp::BaseController.new

      # 既存のツールをクリア
      ActiveMcp::Tool.registered_tools = []

      # テスト用のツールを登録
      require_relative "../../dummy/app/models/public_tool"
      require_relative "../../dummy/app/models/auth_protected_tool"
      require_relative "../../dummy/app/models/admin_only_tool"

      # 明示的に登録
      ActiveMcp::Tool.registered_tools << PublicTool
      ActiveMcp::Tool.registered_tools << AuthProtectedTool
      ActiveMcp::Tool.registered_tools << AdminOnlyTool
    end

    test "should include all tools in tools list without authentication" do
      # 認証なしでツールリストを取得
      post :index, params: { method: "tools/list" }
      assert_response :success

      json = JSON.parse(response.body)
      tools = json["result"]

      # 公開ツールはリストに含まれる
      assert_not_nil tools.find { |t| t["name"] == "public" }

      # 認証が必要なツールはリストに含まれない
      assert_nil tools.find { |t| t["name"] == "auth_protected" }
      assert_nil tools.find { |t| t["name"] == "admin_only" }
    end

    test "should include authorized tools in tools list with valid token" do
      # 有効なトークンで認証
      @request.headers["Authorization"] = "Bearer valid-token"
      post :index, params: { method: "tools/list" }
      assert_response :success

      json = JSON.parse(response.body)
      tools = json["result"]

      # 公開ツールと認証が必要なツールはリストに含まれる
      assert_not_nil tools.find { |t| t["name"] == "public" }
      assert_not_nil tools.find { |t| t["name"] == "auth_protected" }

      # 管理者専用ツールはリストに含まれない
      assert_nil tools.find { |t| t["name"] == "admin_only" }
    end

    test "should include all tools in tools list with admin token" do
      # 管理者トークンで認証
      @request.headers["Authorization"] = "Bearer admin-token"
      post :index, params: { method: "tools/list" }
      assert_response :success

      json = JSON.parse(response.body)
      tools = json["result"]

      # 全てのツールがリストに含まれる
      assert_not_nil tools.find { |t| t["name"] == "public" }
      assert_not_nil tools.find { |t| t["name"] == "auth_protected" }
      assert_not_nil tools.find { |t| t["name"] == "admin_only" }
    end

    test "should allow access to public tool without authentication" do
      arguments = { query: "test" }
      post :index, params: {
        method: "tools/call",
        name: "public",
        arguments: arguments
      }

      assert_response :success
      json = JSON.parse(response.body)
      assert_equal "Public search result for: test", json["result"]
    end

    test "should deny access to protected tool without authentication" do
      arguments = { resource_id: "1", action: "read" }
      post :index, params: {
        method: "tools/call",
        name: "auth_protected",
        arguments: arguments
      }

      assert_response :ok
      json = JSON.parse(response.body)
      assert_not_nil json["error"]
      assert_equal "Unauthorized: Access to tool 'auth_protected' denied", json["error"]
    end

    test "should allow access to protected tool with valid token" do
      @request.headers["Authorization"] = "Bearer valid-token"
      arguments = { resource_id: "1", action: "read" }
      post :index, params: {
        method: "tools/call",
        name: "auth_protected",
        arguments: arguments
      }

      assert_response :success
    end

    test "should deny access to admin tool with regular token" do
      @request.headers["Authorization"] = "Bearer valid-token"
      arguments = { command: "test" }
      post :index, params: {
        method: "tools/call",
        name: "admin_only",
        arguments: arguments
      }

      assert_response :ok
      json = JSON.parse(response.body)
      assert_not_nil json["error"]
      assert_equal "Unauthorized: Access to tool 'admin_only' denied", json["error"]
    end

    test "should allow access to admin tool with admin token" do
      @request.headers["Authorization"] = "Bearer admin-token"
      arguments = { command: "test" }
      post :index, params: {
        method: "tools/call",
        name: "admin_only",
        arguments: arguments
      }

      assert_response :success
      json = JSON.parse(response.body)
      assert_equal "Admin command executed: test", json["result"]
    end
  end
end
