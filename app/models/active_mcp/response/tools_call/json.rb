module ActiveMcp
  module Response
    module ToolsCall
      class Json
        def self.call(params:, auth_info:)
          tool_name = params[:name]

          unless tool_name
            return {
              body: {result: "Invalid params: missing tool name"},
              status: 200,
              isError: true
            }
          end

          tool_class = Tool.registered_tools.find do |tc|
            tc.tool_name == tool_name
          end

          unless tool_class
            return {
              body: {result: "Tool not found: #{tool_name}"},
              status: 200,
              isError: true
            }
          end

          unless tool_class.authorized?(auth_info)
            return {
              body: {result: "Unauthorized: Access to tool '#{tool_name}' denied"},
              status: 401,
              isError: true
            }
          end

          arguments = params[:arguments].permit!.to_hash.symbolize_keys.transform_values { _1.match(/^\d+$/) ? _1.to_i : _1 }

          tool = tool_class.new
          validation_result = tool.validate_arguments(arguments)

          if validation_result.is_a?(Hash) && validation_result[:error]
            return {
              body: {result: validation_result[:error]},
              status: 200,
              isError: true
            }
          end

          begin
            arguments[:auth_info] = auth_info if auth_info.present?

            result = tool.call(**arguments.symbolize_keys)

            return {
              body: {result: result},
              status: 200,
            }
          rescue => e
            return {
              body: {result: "Error: #{e.message}"},
              status: 200,
              isError: true
            }
          end
        end
      end
    end
  end
end
