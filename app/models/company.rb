class Company < ApplicationRecord
  validates :subdomain, :name, presence: true
  validates :subdomain, uniqueness: true
  has_many :users
end
