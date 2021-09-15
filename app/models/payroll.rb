# frozen_string_literal: true

class Payroll < ApplicationRecord
  sequenceid :company, :payrolls
  has_many :applied_benefit
  belongs_to :user
  belongs_to :company

  def self.generates_payroll_object_and_applied_benefits(user_benefits, user)
    gross_salary = calculate_gross_salary(user_benefits, user.base_salary)
    payroll = Payroll.create(user_id: user.id, gross_salary: gross_salary,
                             salary_after_tax: user.base_salary * 0.9, base_salary: user.base_salary)
    generate_applied_benefits(user_benefits, payroll.id, user)
  end

  def self.generate_applied_benefits(user_benefits, payroll_id, user)
    user_benefits.each do |user_benefit|
      AppliedBenefit.create(user_benefit_id: user_benefit.id, payroll_id: payroll_id, amount: user_benefit.amount,
                            benefit_id: user_benefit.benefit_id, user_id: user.id)
    end
  end

  def self.calculate_gross_salary(user_benefits, base_salary, tax = 10)
    gross_salary = base_salary * (1 - (tax / 100))
    user_benefits.each do |benefit|
      gross_salary += benefit.amount
    end
    gross_salary
  end

  def self.check_last_payroll_date(payroll_created_at)
    return false if payroll_created_at.month == DateTime.now.month && payroll_created_at.year == DateTime.now.year

    true
  end
end
