module RegistrationsHelper
  def portal_domain
    if Rails.env.development? 
      "https://<span id='span_subdomain'></span>.teamabc.com".html_safe
    else
      "https://<span id='span_subdomain'></span>.teamabc.com".html_safe
    end
  end
end
