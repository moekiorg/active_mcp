require_relative "lib/active_mcp/version"

Gem::Specification.new do |spec|
  spec.name = "active_mcp"
  spec.version = ActiveMcp::VERSION
  spec.authors = ["Your Name"]
  spec.email = ["your.email@example.com"]
  spec.homepage = "https://github.com/moekiorg/active_mcp"
  spec.summary = "Rails engine for the Model Context Protocol (MCP)"
  spec.description = "A Rails engine that provides MCP capabilities to your Rails application"
  spec.license = "MIT"

  spec.files = Dir.glob("{app,config,db,lib}/**/*") + ["MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 6.0.0", "< 8.0.0"
  spec.add_dependency "json-schema"

  spec.required_ruby_version = ">= 2.7.0"
end
