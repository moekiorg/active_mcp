module ActiveMcp
  class Engine < ::Rails::Engine
    isolate_namespace ActiveMcp

    initializer "active_mcp.eager_load" do |app|
      [
        Rails.root.join("app", "mcp", "tools"),
        Rails.root.join("app", "mcp", "resources"),
        Rails.root.join("app", "mcp", "resource_templates"),
        Rails.root.join("app", "mcp", "prompts"),
        Rails.root.join("app", "mcp", "schemas")
      ].each do |tools_path|
        if Dir.exist?(tools_path)
          Dir[tools_path.join("*.rb")].sort.each do |file|
            require_dependency file
          end
        end
      end
    end
  end
end
