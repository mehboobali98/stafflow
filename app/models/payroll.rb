# frozen_string_literal: true

class Payroll < ApplicationRecord
  sequenceid :company, :payrolls
  has_many :applied_benefits, dependent: :destroy
  belongs_to :user
  belongs_to :company

  def self.generate_payroll(user, users_benefits)
    gross_salary = calculate_gross_salary(user, users_benefits)
    payroll = Payroll.new(user_id: user.id, gross_salary: gross_salary,
                          salary_after_tax: user.base_salary * 0.9, base_salary: user.base_salary)
    users_benefits.each do |users_benefit|
      payroll.applied_benefits.build(users_benefit_id: users_benefit.id, amount: users_benefit.amount,
                                     benefit_id: users_benefit.benefit_id, user_id: user.id)
    end
    payroll.save
  end

  def self.calculate_gross_salary(user, users_benefits)
    # adding salary after tax to gross salary
    gross_salary = user.base_salary * (1 - (user.company.setting.tax_rate / 100))
    users_benefits.each do |benefit|
      gross_salary += benefit.amount
    end
    gross_salary
  end

  def self.check_last_payroll_date(date)
    return false if DateTime.now.month == date.month && DateTime.now.year == date.year

    true
  end
end
