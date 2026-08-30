# frozen_string_literal: true

# Migration options for the Rails 7.1 upgrade.
#
# The app runs on 7.1 but still loads 7.0 defaults, so none of the behaviour
# below has changed yet. Each option is enabled one at a time, with the suite
# run against it, and `config.load_defaults 7.1` replaces this file once they
# are all on.
#
# Most of this release's flips cannot reach this app: it has no `serialize`d
# columns, no `attr_readonly`, no `has_secure_token`, no `after_commit`
# callbacks, no Active Record encryption, no Action Text, and no SQLite. The
# handful that can are called out where they sit.

###
# No longer add autoloaded paths into `$LOAD_PATH`. This means that you won't
# be able to manually require files that are managed by the autoloader, which
# you shouldn't do anyway.
#
# To set this configuration, add the following line to `config/application.rb`
# (NOT this file):
#   config.add_autoload_paths_to_load_path = false

###
# Remove the default X-Download-Options header since it is used only by
# Internet Explorer.
# Rails.application.config.action_dispatch.default_headers = {
#   "X-Frame-Options" => "SAMEORIGIN",
#   "X-XSS-Protection" => "0",
#   "X-Content-Type-Options" => "nosniff",
#   "X-Permitted-Cross-Domain-Policies" => "none",
#   "Referrer-Policy" => "strict-origin-when-cross-origin"
# }

###
# Do not treat an `ActionController::Parameters` instance as equal to an
# equivalent `Hash` by default.
# Rails.application.config.action_controller.allow_deprecated_parameters_hash_equality = false

###
# Active Record Encryption now uses SHA-256 as its hash digest algorithm.
# Nothing here is encrypted with Active Record, so this is the third case in
# the upgrade guide: no data to migrate, take the 7.1+ behaviour.
# Rails.application.config.active_record.encryption.support_sha1_for_non_deterministic_encryption = false

###
# No longer run after_commit callbacks on the first of multiple Active Record
# instances to save changes to the same database row within a transaction.
# Rails.application.config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction = false

###
# Configures SQLite with a strict strings mode.
# Rails.application.config.active_record.sqlite3_adapter_strict_strings_by_default = true

###
# Disable deprecated singular associations names.
# Rails.application.config.active_record.allow_deprecated_singular_associations_name = false

###
# Enable the Active Job `BigDecimal` argument serializer, which guarantees
# roundtripping. Payroll works in BigDecimal and enqueues through delayed_job,
# so this is the one job-serialisation flip with something to bite here.
# Rails.application.config.active_job.use_big_decimal_serializer = true

###
# Raise an `ArgumentError` if `Rails.cache` `fetch` or `write` are given an
# invalid `expires_at` or `expires_in` time.
# Rails.application.config.active_support.raise_on_invalid_cache_expiration_time = true

###
# Format Query Logs tags using the SQLCommenter format rather than the legacy
# one.
# Rails.application.config.active_record.query_log_tags_format = :sqlcommenter

###
# Specify the default serializer used by `MessageEncryptor` and
# `MessageVerifier`. The legacy default is `:marshal`, which is a potential
# vector for deserialization attacks if a signing secret leaks.
#
# This rewrites the session cookie's format. Nothing is deployed, so there are
# no old messages that have to stay readable and no rolling deploy to stage it
# across - both this and the metadata flip below can go on together.
# Rails.application.config.active_support.message_serializer = :json_allow_marshal

###
# Serialize message data and metadata together.
# Rails.application.config.active_support.use_message_serializer_for_metadata = true

###
# Set the maximum size for Rails log files. `config.load_defaults 7.1` does not
# set this value for environments other than development and test.
# if Rails.env.local?
#   Rails.application.config.log_file_size = 100 * 1024 * 1024
# end

###
# Raise on assignment to attr_readonly attributes, rather than silently not
# persisting the change.
# Rails.application.config.active_record.raise_on_assign_to_attr_readonly = true

###
# Validate only parent-related columns for presence when the parent is
# mandatory, rather than querying for the parent on every child update.
# Rails.application.config.active_record.belongs_to_required_validates_foreign_key = false

###
# Precompile `config.filter_parameters`.
# Rails.application.config.precompile_filter_parameters = true

###
# Run before_committed! callbacks on all enrolled records in a transaction.
# Rails.application.config.active_record.before_committed_on_all_records = true

###
# Disable automatic column serialization into YAML.
# Rails.application.config.active_record.default_column_serializer = nil

###
# Serialize Active Record models in a faster and more compact way for the
# cache.
# Rails.application.config.active_record.marshalling_format_version = 7.1

###
# Run `after_commit` and `after_*_commit` callbacks in the order they are
# defined in a model, matching every other callback. Previously they ran in the
# inverse order.
# Rails.application.config.active_record.run_after_transaction_callbacks_in_order_defined = true

###
# Whether a `transaction` block is committed or rolled back when exited via
# `return`, `break` or `throw`.
#
# 7.0 made a non-local return roll the transaction back; this makes it commit.
# `payroll.rb` was restructured during the 6.1 step precisely because it
# returned from inside a transaction, and nothing does that now, so the flip
# has nothing to land on. Worth reading before anyone writes one again.
# Rails.application.config.active_record.commit_transaction_on_non_local_return = true

###
# Control when to generate a value for `has_secure_token` declarations.
# Rails.application.config.active_record.generate_secure_token_on = :initialize

###
# ** Please read carefully, this must be configured in config/application.rb **
# Change the format of the cache entry. Only change this once the app is fully
# deployed on 7.1 with no plans to roll back.
#   config.active_support.cache_format_version = 7.1

###
# Use HTML5 standards-compliant sanitizers in Action View where the platform
# supports them, falling back to the HTML4 sanitizers otherwise.
# Rails.application.config.action_view.sanitizer_vendor = Rails::HTML::Sanitizer.best_supported_vendor

###
# Configure the log level used by the DebugExceptions middleware when logging
# uncaught exceptions during requests.
# Rails.application.config.action_dispatch.debug_exception_log_level = :error

###
# Use HTML5 parsers in the Action View, Action Dispatch and rails-dom-testing
# test helpers. This one is the suite's, not the app's: request specs parse
# rendered pages, so it changes what they see.
# Rails.application.config.dom_testing_default_html_version = :html5
