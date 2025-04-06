module ActiveMcp
  module Response
    module ToolsList
      class Json
        def self.call(tools:)
          {
            result: tools
          }
        end
      end
    end
  end
end
