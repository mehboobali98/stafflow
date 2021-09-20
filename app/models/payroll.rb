# frozen_string_literal: true

class Payroll < ApplicationRecord
  sequenceid :company, :payrolls
  has_many :applied_benefits, dependent: :destroy
  belongs_to :user
  belongs_to :company

  def self.generate_payroll(user)
    tax_amount           = user.base_salary * (user.company.setting.tax_rate / 100)
    salary_after_tax     = user.base_salary - tax_amount
    user_benefits_amount = user.users_benefits.sum(:amount)
    gross_salary         = salary_after_tax + user_benefits_amount

    payroll = Payroll.new(user_id: user.id, gross_salary: gross_salary,
                          salary_after_tax: salary_after_tax, base_salary: user.base_salary)

    user.users_benefits.each do |user_benefit|
      payroll.applied_benefits.build(users_benefit_id: user_benefit.id,
                                     amount: user_benefit.amount,
                                     benefit_id: user_benefit.benefit_id,
                                     user_id: user.id)
    end
    payroll.save
    payroll
  end

  def self.check_last_payroll_date(user)
    date = user.payrolls.last.created_at
    return true if DateTime.now.month == date.month && DateTime.now.year == date.year

    false
  rescue ActiveRecord::RecordInvalid
    false
  end
end
