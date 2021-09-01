class AppliedBenefit < ApplicationRecord
  belongs_to :user_benefit
  belongs_to :payroll
end
