class Company < ApplicationRecord
  def self.find_company_by_subdomain(subdomain)
    Company.find_by_subdomain! subdomain
  end
end
