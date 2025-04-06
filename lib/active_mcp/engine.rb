module ActiveMcp
  class Engine < ::Rails::Engine
    isolate_namespace ActiveMcp

    initializer "active_mcp.eager_load_tools" do |app|
      tools_path = Rails.root.join("app", "tools")
      if Dir.exist?(tools_path)
        Dir[tools_path.join("*.rb")].sort.each do |file|
          require_dependency file
        end
      end
    end
    
    initializer "active_mcp.configure_jbuilder" do |app|
      if Rails.env.development?
        Jbuilder.key_format camelize: :lower
        Jbuilder.prettify if Jbuilder.respond_to?(:prettify) 
      end
    end
  end
end
