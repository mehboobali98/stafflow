class AppliedBenefit < ApplicationRecord
  belongs_to :user_benefit
  belongs_to :payroll
  belongs_to :user
end
