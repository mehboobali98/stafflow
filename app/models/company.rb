class Company < ApplicationRecord
  validates :subdomain, :name, presence: true
end
