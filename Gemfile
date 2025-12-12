source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>= 3.3.6'

# Core Rails
gem 'rails', '~> 8.0.0'
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.4'

# Authentication & Authorization
gem 'bcrypt', '~> 3.1.7'
gem 'jwt', '~> 2.7'
gem 'pundit', '~> 2.3'

# API
gem 'rack-cors'
gem 'jbuilder', '~> 2.11'

# Background Jobs
gem 'sidekiq', '~> 7.2'
gem 'redis', '~> 5.0'

# Utilities
gem 'tzinfo-data', platforms: %i[windows jruby]
gem 'bootsnap', require: false
gem 'faker', '~> 3.2'

# Performance & Monitoring
gem 'lograge', '~> 0.14'
gem 'rack-timeout', '~> 0.6'

group :development, :test do
  gem 'rspec-rails', '~> 6.1'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'pry-rails', '~> 0.3'
  gem 'dotenv-rails', '~> 2.8'
  gem 'rubocop', '~> 1.59', require: false
  gem 'rubocop-rails', '~> 2.23', require: false
  gem 'rubocop-rspec', '~> 2.26', require: false
end

group :test do
  gem 'shoulda-matchers', '~> 6.0'
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'simplecov', require: false
  gem 'webmock', '~> 3.19'
  gem 'vcr', '~> 6.2'
end

group :development do
  # Annotate gem doesn't support Rails 8 yet, removing temporarily
  # gem 'annotate', '~> 3.2'
  # Bullet gem doesn't support Rails 8 yet, removing temporarily
  # gem 'bullet', '~> 7.1'
end
