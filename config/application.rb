require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Stafflow
  class Application < Rails::Application
    config.load_defaults 7.2
    config.active_job.queue_adapter = :delayed_job
    ActionView::Base.field_error_proc = proc do |html_tag, instance|
      html_tag.gsub("form-control", "form-control").html_safe
    end
    config.exceptions_app = self.routes # Add this line

    # Previews live beside the specs rather than under test/, which this app
    # does not have.
    config.view_component.previews.paths << Rails.root.join('spec/components/previews')
    # The default layout reaches for current_user, which a preview has no
    # request to supply, so every preview 500s inside it.
    config.view_component.previews.default_layout = 'component_preview'
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
