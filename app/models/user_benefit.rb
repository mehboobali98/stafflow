class UserBenefit < ApplicationRecord
  belongs_to :benefit
  belongs_to :user
  has_many :applied_benefits, dependent: :destroy
  validates :amount, presence: true
end
