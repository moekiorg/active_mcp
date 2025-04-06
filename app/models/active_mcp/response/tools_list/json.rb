module ActiveMcp
  module Response
    module ToolsList
      class Json
        def self.call(tools:)
          {
            body: { result: tools},
            status: 200
          }
        end
      end
    end
  end
end
