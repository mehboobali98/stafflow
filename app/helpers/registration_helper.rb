module RegistrationsHelper
  def portal_domain
    "https://<span id='span_subdomain'></span>.teamabc.com".html_safe if Rails.env.development?
  end
end
