module ActiveMcp
  class Completion
    def complete(params: {}, context: {}, refs: [])
      ref_name = params.dig(:ref, :name)
      uri_template = params.dig(:ref, :uri)
      arg_name = params.dig(:argument, :name)
      value = params.dig(:argument, :value)

      if uri_template
        resource_class = refs.find { _1.uri_template == uri_template }
        values = resource_class.arguments[arg_name.to_sym].call(value)
        { values:, total: values.length }
      elsif ref_name
        { values: [], total: 0 }
      end
    end
  end
end
