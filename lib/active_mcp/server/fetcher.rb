module ActiveMcp
  class Server
    class Fetcher
      def initialize(base_uri: nil, auth: nil)
        @base_uri = base_uri

        if auth
          @auth_header = "#{(auth[:type] == :bearer) ? "Bearer" : "Basic"} #{auth[:token]}"
        end
      end

      def call(params:)
        return unless @base_uri

        require "net/http"

        unless @base_uri.is_a?(URI) || @base_uri.is_a?(String)
          Server.log_error("Invalid URI type", StandardError.new("URI must be a String or URI object"))
          return
        end

        begin
          uri = URI.parse(@base_uri.to_s)

          unless uri.scheme =~ /\Ahttps?\z/ && !uri.host.nil?
            Server.log_error("Invalid URI", StandardError.new("URI must have a valid scheme and host"))
            return
          end

          if defined?(Rails) && Rails.env.production? && uri.scheme != "https"
            Server.log_error("HTTPS is required in production environment", StandardError.new("Non-HTTPS URI in production"))
            return
          end
        rescue URI::InvalidURIError => e
          Server.log_error("Invalid URI format", e)
          return
        end

        request = Net::HTTP::Post.new(uri)
        request.body = JSON.generate(params)
        request["Content-Type"] = "application/json"
        request["Authorization"] = @auth_header

        begin
          response = Net::HTTP.start(uri.hostname, uri.port) do |http|
            http.request(request)
          end

          JSON.parse(response.body, symbolize_names: true)
        rescue => e
          Server.log_error("Error fetching resource_templates", e)
          nil
        end
      end
    end
  end
end
