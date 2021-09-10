# frozen_string_literal: true

class Company < ApplicationRecord
  validates :name, :subdomain, presence: true
  validates :subdomain, uniqueness: { case_sensitive: false }
  has_many :users, dependent: :destroy
  set_not_multitenant

  def self.current_company_id=(company_id)
    Thread.current[:current_company_id] = company_id
  end

  def self.current_company_id
    Thread.current[:current_company_id]
  end

  def self.find_company_by_subdomain!(subdomain)
    return if subdomain.blank? || subdomain == 'www'

    Company.find_by!(subdomain: subdomain)
  end
end
