source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in active_mcp.gemspec.
# aaa treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# git repositories.
# gem 'rails', github: 'rails/rails'

group :development, :test do
  gem "sqlite3", "~> 1.6.0"
  gem "minitest"
  gem "minitest-reporters"
  gem "json-schema"
  gem "mocha", require: false
end

group :development do
  gem "standard"
end
