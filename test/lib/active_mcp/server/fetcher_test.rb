require "test_helper"
require "net/http"
require "webmock/minitest"

module ActiveMcp
  class Server
    class FetcherTest < ActiveSupport::TestCase
      setup do
        @base_uri = "http://example.com/api"
        @params = {test: "data"}
        # Reset logger messages before each test
        ActiveMcp::Server.logger.instance_variable_set(:@messages, [])
      end

      test "should make HTTP request with correct params" do
        stub_request(:post, @base_uri)
          .with(
            body: @params.to_json,
            headers: {"Content-Type" => "application/json"}
          )
          .to_return(
            status: 200,
            body: {result: "success"}.to_json
          )

        fetcher = Fetcher.new(base_uri: @base_uri)
        response = fetcher.call(params: @params)

        assert_equal({result: "success"}, response)
      end

      test "should include authorization header when auth is provided" do
        auth = {type: :bearer, token: "test-token"}

        stub_request(:post, @base_uri)
          .with(
            headers: {
              "Authorization" => "Bearer test-token",
              "Content-Type" => "application/json"
            }
          )
          .to_return(status: 200, body: "{}")

        fetcher = Fetcher.new(base_uri: @base_uri, auth: auth)
        fetcher.call(params: @params)

        assert_requested :post, @base_uri,
          headers: {"Authorization" => "Bearer test-token"}
      end

      test "should handle basic auth type" do
        auth = {type: :basic, token: "basic-token"}

        stub_request(:post, @base_uri)
          .with(
            headers: {
              "Authorization" => "Basic basic-token",
              "Content-Type" => "application/json"
            }
          )
          .to_return(status: 200, body: "{}")

        fetcher = Fetcher.new(base_uri: @base_uri, auth: auth)
        fetcher.call(params: @params)

        assert_requested :post, @base_uri,
          headers: {"Authorization" => "Basic basic-token"}
      end

      test "should validate URI format" do
        fetcher = Fetcher.new(base_uri: "invalid-uri")
        response = fetcher.call(params: @params)

        assert_nil response
      end

      test "should validate URI scheme" do
        fetcher = Fetcher.new(base_uri: "ftp://example.com")
        response = fetcher.call(params: @params)

        assert_nil response
      end

      test "should require HTTPS in production" do
        Rails.env.stubs(:production?).returns(true)

        fetcher = Fetcher.new(base_uri: "http://example.com")
        response = fetcher.call(params: @params)

        assert_nil response
      end

      test "should handle request errors" do
        stub_request(:post, @base_uri).to_timeout

        fetcher = Fetcher.new(base_uri: @base_uri)
        fetcher.call(params: @params)

        error = ActiveMcp::Server.logger.messages.last
        assert_match(/Error fetching resource_templates/, error[:message])
        assert_instance_of Net::OpenTimeout, error[:error]
      end
    end
  end
end
