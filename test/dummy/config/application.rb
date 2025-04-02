require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile
Bundler.require(*Rails.groups)
require "active_mcp"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::MAJOR + Rails::VERSION::MINOR.to_f / 10.0

    # For Rails 7.2
    config.active_support.cache_format_version = 7.1 if config.respond_to?(:active_support)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Do not generate assets or helper modules
    config.generators do |g|
      g.assets false
      g.helper false
      g.test_framework :test_unit, fixture: false
    end
  end
end
