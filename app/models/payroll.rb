# frozen_string_literal: true

class Payroll < ApplicationRecord
  has_many :applied_benefits
  belongs_to :user
end
