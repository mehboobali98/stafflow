class UserBenefit < ApplicationRecord
  belongs_to :benefit
  belongs_to :user
  has_many :applied_benefits, dependent: :nullify
  validates :amount, presence: true
  def self.create_applied_benefit
    @user_benefit = UserBenefit.all
    @user_benefit.each do |user_benefit|
      if user_benefit.status
        AppliedBenefit.create(amount: user_benefit.amount, user_benefit_id: user_benefit.id, payroll_id: nil,
                              user_id: user_benefit.id)
      end
    end
  end
end
