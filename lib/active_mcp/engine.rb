module ActiveMcp
  class Engine < ::Rails::Engine
    isolate_namespace ActiveMcp

    initializer "active_mcp.eager_load" do |app|
      [
        Rails.root.join("app", "mcp", "tools"),
        Rails.root.join("app", "mcp", "resources"),
        Rails.root.join("app", "mcp", "prompts"),
        Rails.root.join("app", "mcp", "schemas")
      ].each do |path|
        if Dir.exist?(path)
          app.autoloaders.main.push_dir(path)
        end
      end
    end
  end
end
