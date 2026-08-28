# frozen_string_literal: true

class Company < ApplicationRecord
  validates :name, :subdomain, presence: true
  validates :subdomain, uniqueness: { case_sensitive: false }
  has_one :setting, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :benefits, dependent: :destroy
  has_many :users_benefits
  has_many :payrolls, dependent: :destroy
  has_many :applied_benefits
  has_many :departments, dependent: :destroy
  has_many :designations, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :leaves, dependent: :destroy
  has_many :user_leaves
  has_many :applied_leaves

  set_not_multitenant
  # Only on create. Run on every save this replaced the company's configured
  # settings with a fresh default-rate row, so any later edit to the company
  # silently reverted the tax rate and every payroll after it was wrong.
  before_create :build_company_setting

  def self.current_company_id=(company_id)
    Thread.current[:current_company_id] = company_id
  end

  def self.current_company_id
    Thread.current[:current_company_id]
  end

  def self.find_company_by_subdomain!(subdomain)
    Company.find_by!(subdomain: subdomain)
  end

  def build_company_setting
    build_setting(tax_rate: DEFAULT_TAX_RATE)
  end
end
