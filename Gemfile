source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in scheduler.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

group :development, :test do
  # Awesome console
  gem 'awesome_rails_console'
  gem 'hirb'
  gem 'hirb-unicode'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  # Test
  gem 'rspec-rails'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'faker', :git => 'https://github.com/stympy/faker.git', :branch => 'master'
end

# To use a debugger
# gem 'byebug', group: [:development, :test]
