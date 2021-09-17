module RegistrationsHelper
  def portal_domain
    return "https://<span id='span_subdomain'></span>.teamabc.com".html_safe if Rails.env.development?
    "https://<span id='span_subdomain'></span>.teamabc.com".html_safe
  end
end
