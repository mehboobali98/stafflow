class UserBenefit < ApplicationRecord
  belongs_to :benefit
  has_many :applied_benefits, dependent: :destroy
  validates :amount, presence: true
end
