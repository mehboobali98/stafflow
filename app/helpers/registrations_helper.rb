# frozen_string_literal: true

module RegistrationsHelper
  # Domain the tenant subdomain is appended to on the sign-up form. The
  # placeholder span is filled in as the user types (see packs/signup.js).
  def portal_domain
    domain = ENV.fetch('STAFFLOW_PORTAL_DOMAIN', 'stafflow.example')
    "https://<span id='span_subdomain'></span>.#{ERB::Util.html_escape(domain)}".html_safe
  end
end
