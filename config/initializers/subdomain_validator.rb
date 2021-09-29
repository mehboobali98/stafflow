# frozen_string_literal: true

class SubdomainValidator
  def self.subdomain_given?(request)
    request.subdomain.present?
  end
end
