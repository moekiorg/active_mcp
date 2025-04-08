source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

group :development do
  gem "standard"
end

group :test do
  gem "sqlite3"
  gem 'simplecov', require: false, group: :test
  gem "minitest"
  gem "minitest-reporters"
  gem "mocha", require: false
end
