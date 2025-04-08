module ActiveMcp
  module ResourceReadable
    extend ActiveSupport::Concern

    private

    def read_resource(params:, context:)
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

      resource = schema.resources.find do |r|
        r.uri == uri
      end

      unless resource
        return {
          isError: true,
          contents: []
        }
      end

      if resource.respond_to?(:visible?) && !resource.visible?(context:)
        return {
          isError: true,
          contents: []
        }
      end

      begin
        if resource.respond_to?(:text) && content = resource.content
          return {
            contents: [
              {
                uri:,
                mimeType: resource.class.mime_type,
                text: content
              }
            ]
          }
        elsif content = resource.blob
          return {
            contents: [
              {
                uri:,
                mimeType: resource.class.mime_type,
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
  end
end
