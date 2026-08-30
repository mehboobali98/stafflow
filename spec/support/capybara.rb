# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara/cuprite'

# `driven_by :cuprite` is not just a name lookup: Rails registers the driver
# itself, overwriting whatever was registered under that name first. A
# Capybara.register_driver(:cuprite) block here would look like it configured
# the browser and would silently do nothing. Options only survive by being
# handed to driven_by, which is what rails_helper.rb does with these.
CUPRITE_OPTIONS = {
  # no-sandbox because the container runs as root, and disable-dev-shm-usage
  # because Docker gives /dev/shm 64MB, which Chromium exhausts and answers by
  # killing the tab mid-example.
  browser_options: { 'no-sandbox' => nil, 'disable-dev-shm-usage' => nil },
  process_timeout: 30,
  timeout: 20,
  headless: true,
  # This is the line the suite was missing. An uncaught exception in the page
  # raises in the example instead of sitting in a console nothing reads:
  # `require.context` threw on line 4 of every page for two releases while the
  # build stayed green and every request spec passed.
  js_errors: true
}.freeze

Capybara.default_max_wait_time = 10

# Capybara serves the app on 127.0.0.1 and a random port, and the tenant is
# resolved from the request subdomain. Chromium routes any *.localhost name to
# loopback without consulting DNS, so an app_host set to one reaches this server
# and arrives carrying a subdomain. always_include_port appends the port, which
# a host written out by hand cannot know.
Capybara.always_include_port = true
