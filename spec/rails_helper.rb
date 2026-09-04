# frozen_string_literal: true

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'view_component/test_helpers'
require 'shoulda/matchers'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
  config.include TenantHelpers
  config.include AttachmentHelpers
  config.include SystemHelpers, type: :system
  config.include ContrastHelpers, type: :system
  config.include AccessibilityHelpers, type: :system
  config.include ViewComponent::TestHelpers, type: :component

  # rspec-rails drives an unset system spec with :selenium. CUPRITE_OPTIONS and
  # the reason they are passed here rather than registered are in
  # spec/support/capybara.rb. It is duped because driven_by deletes a key from
  # what it is handed, and raises on the frozen original.
  config.before(:each, type: :system) do
    driven_by :cuprite, screen_size: [1400, 1400], options: CUPRITE_OPTIONS.dup
  end

  # app_host is global to Capybara, so a spec that finished on a subdomain
  # would hand it to whichever spec ran next.
  config.after(:each, type: :system) { Capybara.app_host = nil }

  # Every tenant-owned model carries a default scope keyed on
  # Company.current_company_id. Leaving it set between examples would leak
  # tenant context across the suite, so it is always cleared.
  config.after { Company.current_company_id = nil }
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
