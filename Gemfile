
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.12'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
# The lower bound is a security floor rather than a preference. 7.2.3.2 carries
# the fix for GHSA-xr9x-r78c-5hrm, arbitrary file read through Active Storage
# variant processing, and `~> 7.2.3` on its own resolves to 7.2.3.
gem 'rails', '~> 7.2.3', '>= 7.2.3.2'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.4.4'
# Use Puma as the app server
gem 'puma', '~> 8.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# esbuild builds into app/assets/builds; Sprockets fingerprints and serves it.
gem 'jsbundling-rails', '~> 1.3'
# Font Awesome through Sprockets rather than the bundler. The npm package ships
# plain CSS whose font URLs esbuild rewrites at build time, which Sprockets then
# fingerprints a second time - so the URLs in the stylesheet point at names that
# only exist undigested, and every icon 404s once assets are precompiled. This
# gem uses the asset helpers, so the digests match.
gem 'font-awesome-sass', '~> 5.15.1'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Active Storage variants. The 7.0 framework defaults select the vips
# processor, so the image is built with libvips rather than ImageMagick.
gem 'image_processing', '~> 1.12'
# Active Storage ships no content-type or size validators of its own. Sniffing
# upload types by hand is where this kind of code goes wrong, so it is left to
# a gem that validates the analysed type rather than the declared one.
gem 'active_storage_validations', '~> 1.1'
gem 'will_paginate', '=3.3.0'
# additional gems
gem 'cancancan'
gem 'devise', '~> 5.0'
gem 'has_scope', '0.8.0'
gem 'pry', '~> 0.14.1'
gem 'pry-rails', '~> 0.3.9'
gem 'delayed_job', '~> 4.1'
gem 'delayed_job_active_record', '~> 4.1.7'
gem 'transitions', '=1.2.1', require: %w[transitions active_model/transitions]

# cron job
gem 'whenever', '=1.0.0', require: false

# calendar gem
gem 'simple_calendar', '=2.4.3'

# graphs
# The gem renders the tag and the npm package draws into it, so the two move
# together: chartkick.js 5 is what wants Chart.js 4, and the gem below is what
# knows how to talk to it.
gem 'chartkick', '~> 5.2'

# elastic search
gem 'searchkick', '~> 5.3'
# searchkick 5 dropped its dependency on a client gem so it can drive either
# Elasticsearch or OpenSearch. The client is ours to choose and ours to keep in
# step with the server: this tracks the Elasticsearch 7 that docker-compose and
# CI run, and has to move with them.
gem 'elasticsearch', '~> 7.17'

# faker gem to seed database
gem 'faker', '=2.19.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

gem 'breadcrumbs_on_rails', '=4.1.0'

# The component layer. Views hand-wrote `btn btn-*` in 49 places and a bare
# `<table>` in 18 before this; the point is one place to change each of them.
gem 'view_component', '~> 4.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'brakeman', '~> 5.2', require: false
  gem 'factory_bot', '~> 6.4'
  gem 'factory_bot_rails', '~> 6.5'
  gem 'rspec-rails', '~> 6.1'
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
  gem 'spring-watcher-listen', '~> 2.1.0'
  # Renders the component previews. Development only: it is a build tool, and
  # whether the demo should expose it is a phase 4 question, not settled here.
  gem 'lookbook', '~> 2.3'
end

group :test do
  gem 'shoulda-matchers', '~> 5.0'
  gem 'capybara', '~> 3.40'
  # Cuprite drives Chrome over CDP, so there is no chromedriver to keep in step
  # with the browser - the coupling that left `webdrivers` pinning selenium
  # below 4.0 until both were deleted. It is also what makes `js_errors: true`
  # possible: an uncaught exception in the page raises in the example rather
  # than being left in a log for the spec to go looking for.
  gem 'cuprite', '~> 0.17'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
