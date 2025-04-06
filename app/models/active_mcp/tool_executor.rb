module ActiveMcp
  module ToolExecutor
    def self.call(params:, auth_info:)
      tool_name = params[:name]

      unless tool_name
        return {
          isError: true,
          content: [
            {
              type: "text",
              text: "Invalid params: missing tool name",
            }
          ]
        }
      end

      tool_class = Tool.registered_tools.find do |tc|
        tc.tool_name == tool_name
      end

      unless tool_class
        return {
          isError: true,
          content: [
            {
              type: "text",
              text: "Tool not found: #{tool_name}",
            }
          ]
        }
      end

      unless tool_class.visible?(auth_info)
        return {
          isError: true,
          content: [
            {
              type: "text",
              text: "Unauthorized: Access to tool '#{tool_name}' denied",
            }
          ]
        }
      end

      arguments = params[:arguments].permit!.to_hash.symbolize_keys.transform_values do |value|
        if !value.is_a?(String)
          value
        else
          value.match(/^\d+$/) ? value.to_i : value
        end
      end

      tool = tool_class.new
      validation_result = tool.validate_arguments(arguments)

      if validation_result.is_a?(Hash) && validation_result[:error]
        return {
          isError: true,
          content: [
            {
              type: "text",
              text: validation_result[:error],
            }
          ]
        }
      end

      begin
        arguments[:auth_info] = auth_info if auth_info.present?

        return {
          content: [
            {
              type: "text",
              text: formatted(tool.call(**arguments.symbolize_keys))
            }
          ]
        }
      rescue => e
        return {
          isError: true,
          content: [
            {
              type: "text",
              text: "Error: #{e.message}",
            }
          ]
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
