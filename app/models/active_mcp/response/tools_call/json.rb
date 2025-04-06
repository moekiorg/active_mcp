module ActiveMcp
  module Response
    module ToolsCall
      class Json
        def self.call(params:, auth_info:)
          ActiveMcp::ToolExecutor.call(params:, auth_info:)
        end
      end
    end
  end
end
