
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.7'
# 1.3.5 dropped a `require 'logger'` that ActiveSupport < 7.1 depends on. Fails
# in bin/webpack rather than the suite, so removing this pin looks safe and is
# not. Comes out at Rails 7.1.
gem 'concurrent-ruby', '< 1.3.5'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.4.4'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'paperclip', '=6.0.0'
gem 'will_paginate', '=3.3.0'
# additional gems
gem 'cancancan'
gem 'devise'
gem 'has_scope', '0.8.0'
gem 'pry', '~> 0.14.1'
gem 'pry-rails', '~> 0.3.9'
gem 'delayed_job_active_record', '4.1.6'
gem 'transitions', '=1.2.1', require: %w[transitions active_model/transitions]

# cron job
gem 'whenever', '=1.0.0', require: false

# calendar gem
gem 'simple_calendar', '=2.4.3'

# graphs
gem 'chartkick', '=4.0.5'

# elastic search
gem 'searchkick', '=4.6.0'

# faker gem to seed database
gem 'faker', '=2.19.0'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

gem 'breadcrumbs_on_rails', '=4.1.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'brakeman', '~> 5.2', require: false
  gem 'factory_bot', '~> 6.4'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'rspec-rails', '~> 5.1'
  gem 'rubocop', '~> 1.28', require: false
  gem 'rubocop-rails', '~> 2.14', require: false
  gem 'rubocop-rspec', '~> 2.10', require: false
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '~> 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  gem 'shoulda-matchers', '~> 5.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
