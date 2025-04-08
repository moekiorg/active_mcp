module ActiveMcp
  module ResourceReadable
    extend ActiveSupport::Concern

    private

    def read_resource(params:, context:)
      uri = if params[:jsonrpc].present?
        params[:params][:uri]
      else
        params[:uri]
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
        if resource.respond_to?(:text) && (content = resource.content)
          {
            contents: [
              {
                uri:,
                mimeType: resource.class.mime_type,
                text: content
              }
            ]
          }
        elsif (content = resource.blob)
          {
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
        {
          isError: true,
          contents: []
        }
      end
    end
  end
end
