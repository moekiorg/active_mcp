require_relative "lib/active_mcp/version"

Gem::Specification.new do |spec|
  spec.name = "active_mcp"
  spec.version = ActiveMcp::VERSION
  spec.authors = ["Moeki Kawakami"]
  spec.email = ["hi@moeki.org"]
  spec.homepage = "https://github.com/moekiorg/active_mcp"
  spec.summary = "Rails engine for the Model Context Protocol (MCP)"
  spec.description = "A Rails engine that provides MCP capabilities to your Rails application"
  spec.license = "MIT"

  spec.files = Dir.glob("{app,config,db,lib}/**/*") + ["MIT-LICENSE", "Rakefile", "README.md"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 6.0.0", "< 8.0.0"
  spec.add_dependency "json-schema"
  spec.add_dependency "jbuilder", ">= 2.7"

  spec.required_ruby_version = ">= 2.7.0"
end
