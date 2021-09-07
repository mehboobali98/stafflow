# frozen_string_literal: true

class Payroll < ApplicationRecord
  has_many :applied_benefit
  belongs_to :user

  def self.calculate_gross_salary(user_benefit, payroll)
    salary = 0
    salary += payroll.salary_after_tax
    user_benefit.each do |benefit|
      salary += benefit.amount
    end
    salary
  end
end
