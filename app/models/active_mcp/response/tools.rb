module ActiveMcp
  module Response
    class Tools
      def self.to_hash(auth_info:)
        Tool.registered_tools.select do |tool_class|
          tool_class.authorized?(auth_info)
        end.map do |tool_class|
          {
            name: tool_class.tool_name,
            description: tool_class.desc,
            inputSchema: tool_class.schema
          }
        end
      end
    end
  end
end
