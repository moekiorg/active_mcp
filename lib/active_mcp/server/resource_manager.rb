require "json"

module ActiveMcp
  class Server
    class ResourceManager
      attr_reader :resources

      def initialize(uri: nil, auth: nil)
        @resources = {}
        @base_uri = uri

        if auth
          @auth_header = "#{auth[:type] == :bearer ? "Bearer" : "Basic"} #{auth[:token]}"
        end
      end

      def load_registered_resources
        fetch_resources
      end

      def read_resource(uri)
        require "net/http"
        
        unless @base_uri.is_a?(URI) || @base_uri.is_a?(String)
          log_error("Invalid URI type", StandardError.new("URI must be a String or URI object"))
          return {
            isError: true,
            content: [{type: "text", text: "Invalid URI configuration"}]
          }
        end
        
        begin
          base_uri = URI.parse(@base_uri.to_s)
          
          unless base_uri.scheme =~ /\Ahttps?\z/ && !base_uri.host.nil?
            log_error("Invalid URI", StandardError.new("URI must have a valid scheme and host"))
            return {
              isError: true,
              content: [{type: "text", text: "Invalid URI configuration"}]
            }
          end
          
          if defined?(Rails) && Rails.env.production? && base_uri.scheme != "https"
            return {
              isError: true,
              content: [{type: "text", text: "HTTPS is required in production environment"}]
            }
          end
        rescue URI::InvalidURIError => e
          log_error("Invalid URI format", e)
          return {
            isError: true,
            content: [{type: "text", text: "Invalid URI format"}]
          }
        end
        
        request = Net::HTTP::Post.new(base_uri)
        request.body = JSON.generate({
          method: Method::RESOURCES_READ,
          uri:,
        })
        request["Content-Type"] = "application/json"
        request["Authorization"] = @auth_header

        begin
          response = Net::HTTP.start(base_uri.hostname, base_uri.port) do |http|
            http.request(request)
          end

          if response.code == "200"
            JSON.parse(response.body, symbolize_names: true)
          else
            $stderr.puts(response.body)
            {
              isError: true,
              contents: []
            }
          end
        rescue => e
          log_error("Error calling tool", e)
          {
            isError: true,
            contents: []
          }
        end
      end

      private

      def fetch_resources
        return unless @base_uri

        require "net/http"
        
        unless @base_uri.is_a?(URI) || @base_uri.is_a?(String)
          log_error("Invalid URI type", StandardError.new("URI must be a String or URI object"))
          return
        end
        
        begin
          uri = URI.parse(@base_uri.to_s)
          
          unless uri.scheme =~ /\Ahttps?\z/ && !uri.host.nil?
            log_error("Invalid URI", StandardError.new("URI must have a valid scheme and host"))
            return
          end
          
          if defined?(Rails) && Rails.env.production? && uri.scheme != "https"
            log_error("HTTPS is required in production environment", StandardError.new("Non-HTTPS URI in production"))
            return
          end
        rescue URI::InvalidURIError => e
          log_error("Invalid URI format", e)
          return
        end
        
        request = Net::HTTP::Post.new(uri)
        request.body = JSON.generate({
          method: "resources/list",
          arguments: "{}"
        })
        request["Content-Type"] = "application/json"
        request["Authorization"] = @auth_header

        begin
          response = Net::HTTP.start(uri.hostname, uri.port) do |http|
            http.request(request)
          end

          result = JSON.parse(response.body, symbolize_names: true)
          @resources = result[:result]
        rescue => e
          log_error("Error fetching resources", e)
          @resources = []
        end
      end
      
      def log_error(message, error)
        error_details = "#{message}: #{error.message}\n"
        error_details += error.backtrace.join("\n") if error.backtrace
        
        if defined?(Rails)
          Rails.logger.error(error_details)
        else
          $stderr.puts(error_details)
        end
      end
    end
  end
end
