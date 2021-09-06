# frozen_string_literal: true

class Company < ApplicationRecord
  validates :name, :subdomain, presence: true
  validates :subdomain, uniqueness: { case_sensitive: false }
  set_not_multitenant

  def self.current_company_id=(company_id)
    Thread.current[:current_company_id] = company_id
  end

  def self.current_company_id
    Thread.current[:current_company_id]
  end

  def self.find_company_by_subdomain!(subdomain)
    Company.find_by!(subdomain: subdomain)
  end
end
