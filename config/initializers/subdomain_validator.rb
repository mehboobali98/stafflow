class SubdomainValidator
  def self.check_if_subdomain_given?(request)
    request.subdomain.present?
  end
end
