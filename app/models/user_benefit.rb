class UserBenefit < ApplicationRecord
  belongs_to :benefit
  belongs_to :user
  has_many :applied_benefits, dependent: :nullify
  validates :amount, presence: true
end
