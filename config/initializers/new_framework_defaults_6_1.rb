# frozen_string_literal: true

# Migration options for the Rails 6.1 upgrade.
#
# The app runs on 6.1 but still loads 6.0 defaults, so none of the behaviour
# below has changed yet. Each option is enabled one at a time, with the suite
# run against it, and `config.load_defaults 6.1` replaces this file once they
# are all on.
#
# Two of these are not cosmetic for this app and are called out where they sit:
# the `form_with` change and the SameSite cookie change.

# Support for inversing belongs_to -> has_many Active Record associations.
# Rails.application.config.active_record.has_many_inversing = true

# Track Active Storage variants in the database.
# Rails.application.config.active_storage.track_variants = true

# Apply random variation to the delay when retrying failed jobs.
# Rails.application.config.active_job.retry_jitter = 0.15

# Stop executing `after_enqueue`/`after_perform` callbacks if
# `before_enqueue`/`before_perform` respectively halts with `throw :abort`.
# Rails.application.config.active_job.skip_after_callbacks_if_terminated = true

# Cookies are scoped to a tenant subdomain here, and sign-in crosses from the
# apex marketing page to `<tenant>.host`. Check that flow by hand before
# enabling this - a :lax cookie is not sent on cross-site POSTs.
# Rails.application.config.action_dispatch.cookies_same_site_protection = :lax

# Generate CSRF tokens that are encoded in URL-safe Base64.
# Rails.application.config.action_controller.urlsafe_csrf_tokens = true

# Specify whether `ActiveSupport::TimeZone.utc_to_local` returns a time with a
# UTC offset or a UTC time.
# ActiveSupport.utc_to_local_returns_utc_offset_times = true

# Change the default HTTP status code to `308` when redirecting non-GET/HEAD
# requests to HTTPS in `ActionDispatch::SSL` middleware.
# Rails.application.config.action_dispatch.ssl_default_redirect_status = 308

# Use new connection handling API.
# Rails.application.config.active_record.legacy_connection_handling = false

# `app/views/users_benefits/new.html.erb` and
# `app/views/applied_leaves/new_applied_leave_by_hr.html.erb` call `form_with`
# without `local: true`, so they submit over XHR today. Enabling this turns them
# into ordinary page submits, and their controllers only answer `format.html`.
# Give both forms an explicit `local:` before turning this on.
# Rails.application.config.action_view.form_with_generates_remote_forms = false

# Set the default queue name for the analysis job to the queue adapter default.
# Rails.application.config.active_storage.queues.analysis = nil

# Set the default queue name for the purge job to the queue adapter default.
# Rails.application.config.active_storage.queues.purge = nil

# Set the default queue name for the incineration job to the queue adapter default.
# Rails.application.config.action_mailbox.queues.incineration = nil

# Set the default queue name for the routing job to the queue adapter default.
# Rails.application.config.action_mailbox.queues.routing = nil

# Set the default queue name for the mail deliver job to the queue adapter default.
# Rails.application.config.action_mailer.deliver_later_queue_name = nil

# Generate a `Link` header that gives a hint to modern browsers about
# preloading assets when using `javascript_include_tag` and
# `stylesheet_link_tag`.
# Rails.application.config.action_view.preload_links_header = true
