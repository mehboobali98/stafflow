# frozen_string_literal: true

class AppliedBenefit < ApplicationRecord
  belongs_to :user_benefit
  belongs_to :payroll
  belongs_to :user
  belongs_to :benefit
end
