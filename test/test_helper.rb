# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

ENV["DATABASE_URL"] = "sqlite3::memory:"

require_relative "../test/dummy/config/environment"
require_relative "./fixtures/dummy_prompt"
require_relative "./fixtures/dummy_resource"
require "rails/test_help"
require "minitest/reporters"
require "mocha/minitest"
require "minitest/mock"

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

# Filter out the backtrace from minitest while preserving the one from other libraries.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end
