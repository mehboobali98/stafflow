# frozen_string_literal: true

class Payroll < ApplicationRecord
  sequenceid :company, :payrolls
  has_many :applied_benefits, dependent: :destroy
  belongs_to :user
  belongs_to :company
  validate :validate_payroll_existence, on: :create
  validate :validate_payroll_date, on: :create

  def self.generate_payroll(user)
    gross_salary = calculate_gross_salary(user)
    payroll = Payroll.create(user_id: user.id, gross_salary: gross_salary,
                             salary_after_tax: user.base_salary * 0.9, base_salary: user.base_salary)
    generate_applied_benefits(users_benefits, payroll.id, user)
  end

  def self.generate_applied_benefits(users_benefits, payroll_id, user)
    users_benefits.each do |users_benefit|
      AppliedBenefit.create(users_benefit_id: users_benefit.id, payroll_id: payroll_id, amount: users_benefit.amount,
                            benefit_id: users_benefit.benefit_id, user_id: user.id)
    end
  end

  def self.calculate_gross_salary(user)
    gross_salary = user.base_salary * (1 - (tax.to_f / 100))
    user.users_benefits.each do |benefit|
      gross_salary += benefit.amount
    end
    gross_salary
  end

  def validate_payroll_existence
    true if @payroll.exists?

    false
  end

  def validate_payroll_date
    return false if payroll_created_at.month == DateTime.now.month && payroll_created_at.year == DateTime.now.year

    true
  end
end
