module ActiveMcp
  module ResourceReadable
    extend ActiveSupport::Concern

    private

    def read_resource(params:, context:)
      uri = params[:params][:uri]

      unless uri
        return {
          isError: true,
          contents: []
        }
      end

      resource = schema.visible_resources.find do |r|
        r.uri == uri
      end

      unless resource
        return {
          isError: true,
          contents: []
        }
      end

      if resource.class.respond_to?(:visible?) && !resource.class.visible?(context:)
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
                mimeType: resource.class.mime_type_value,
                text: content
              }
            ]
          }
        elsif (content = resource.blob)
          {
            contents: [
              {
                uri:,
                mimeType: resource.class.mime_type_value,
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
