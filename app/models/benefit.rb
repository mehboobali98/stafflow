class Benefit < ApplicationRecord
  has_many :user_benefits
  has_many :applied_benefits
  validates :name, uniqueness: true
  validates :name, presence: { message: 'This field cannot be left empty' }
  validates :benefit_type, presence: { message: 'This field cannot be left empty' }
end
