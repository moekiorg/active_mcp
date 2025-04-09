module ActiveMcp
  module ToolExecutable
    extend ActiveSupport::Concern

    private

    def execute_tool(params:, context: {})
      if params[:jsonrpc].present?
        tool_name = params[:params][:name]
        tool_params = params[:params][:arguments]
      else
        tool_name = params[:name]
        tool_params = params[:arguments]
      end

      unless tool_name
        return {
          isError: true,
          content: [
            {
              type: "text",
              text: "Invalid params: missing tool name"
            }
          ]
        }
      end

      tool = schema.visible_tools.find do |tc|
        tc.tool_name == tool_name
      end

      unless tool
        return {
          isError: true,
          content: [
            {
              type: "text",
              text: "Tool not found: #{tool_name}"
            }
          ]
        }
      end

      unless tool.visible?(context:)
        return {
          isError: true,
          content: [
            {
              type: "text",
              text: "Unauthorized: Access to tool '#{tool_name}' denied"
            }
          ]
        }
      end

      arguments = if tool_params.is_a?(String)
        JSON.parse(tool_params).symbolize_keys
      elsif tool_params
        tool_params.permit!.to_hash.symbolize_keys
      else
        {}
      end

      arguments = arguments.transform_values do |value|
        if !value.is_a?(String)
          value
        else
          /^\d+$/.match?(value) ? value.to_i : value
        end
      end

      validation_result = tool.validate_arguments(arguments)

      if validation_result.is_a?(Hash) && validation_result[:error]
        return {
          isError: true,
          content: [
            {
              type: "text",
              text: validation_result[:error]
            }
          ]
        }
      end

      # Execute the tool
      begin
        {
          content: [
            {
              type: "text",
              text: formatted(tool.call(**arguments, context:))
            }
          ]
        }
      rescue => e
        {
          isError: true,
          content: [
            {
              type: "text",
              text: "Error: #{e.message}"
            }
          ]
        }
      end
    end

    def formatted(object)
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
