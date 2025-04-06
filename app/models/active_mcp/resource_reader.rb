module ActiveMcp
  class ResourceReader
    def self.read(params:, auth_info:)
      if params[:jsonrpc].present?
        uri = params[:params][:uri]
      else
        uri = params[:uri]
      end
      
      unless uri
        return {
          isError: true,
          contents: []
        }
      end

      resource_class = Resource.registered_resources.find do |r|
        r._uri == uri
      end
      
      unless resource_class
        return {
          isError: true,
          contents: []
        }
      end
      
      unless resource_class.visible?(auth_info)
        return {
          isError: true,
          contents: []
        }
      end

      resource = resource_class.new

      begin
        if content = resource.text(auth_info:)
          return {
            contents: [
              {
                uri:,
                mimeType: resource_class._mime_type,
                text: formatted(content)
              }
            ]
          }
        elsif content = resource.blob(auth_info:)
          return {
            contents: [
              {
                uri:,
                mimeType: resource_class._mime_type,
                blob: Base64.strict_encode64(content)
              }
            ]
          }
        end
      rescue
        return {
          isError: true,
          contents: []
        }
      end
    end
    
    def self.formatted(object)
      case object
      when String
        object
      when Hash
        object.to_json
      else
        object.to_s
      end
    end
  end
end
