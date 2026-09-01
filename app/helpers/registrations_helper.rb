# frozen_string_literal: true

module RegistrationsHelper
  # Domain the tenant subdomain is appended to on the sign-up form. The
  # placeholder span is filled in as the company name is typed, by the
  # subdomain Stimulus controller the form declares.
  def portal_domain
    domain = ENV.fetch('STAFFLOW_PORTAL_DOMAIN', 'stafflow.example')
    placeholder = tag.span(id: 'span_subdomain', data: { subdomain_target: 'preview' })

    safe_join(['https://', placeholder, ".#{domain}"])
  end
end
