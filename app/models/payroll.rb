# frozen_string_literal: true

class Payroll < ApplicationRecord
  has_many :applied_benefit
  belongs_to :user
  belongs_to :company

  def self.calculate_gross_salary(user_benefit)
    gross_salary = 0
    gross_salary += user_benefit.first.user.base_salary * 0.9
    user_benefit.each do |benefit|
      gross_salary += benefit.amount
    end
    gross_salary
  end

  def self.generate_payroll(user_benefit)
    gross_salary = calculate_gross_salary(user_benefit)
    user_benefit = user_benefit.first
    payroll = Payroll.new(user_id: user_benefit.user.id, gross_salary: gross_salary,
                          salary_after_tax: user_benefit.user.base_salary * 0.9)
    payroll.save
    payroll.id
  end

  def self.generate_applied_benefits(user_benefits, payroll_id)
    user_benefits.each do |user_benefit|
      applied_benefit_object = AppliedBenefit.new(user_benefit_id: user_benefit.id, payroll_id: payroll_id, amount: user_benefit.amount,
                                                  benefit_id: user_benefit.benefit_id, user_id: user_benefit.user.id)
      applied_benefit_object.save
    end
  end
end
