# frozen_string_literal: true

class AppliedBenefit < ApplicationRecord
  belongs_to :users_benefit
  belongs_to :payroll
  belongs_to :user
  belongs_to :benefit
  belongs_to :company
end
