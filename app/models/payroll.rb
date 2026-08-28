# frozen_string_literal: true

class Payroll < ApplicationRecord
  include CompanySequenced
  has_many :applied_benefits, dependent: :destroy
  belongs_to :user
  belongs_to :company
  after_create :deliver_payroll_generation_email

  def self.generate_payroll(user)
    ActiveRecord::Base.transaction do
      tax_amount           = user.base_salary * (user.company.setting.tax_rate / 100)
      salary_after_tax     = user.base_salary - tax_amount
      user_benefits_amount = user.users_benefits.sum(:amount)
      gross_salary         = salary_after_tax + user_benefits_amount

      payroll = user.payrolls.new(user_id: user.id, gross_salary: gross_salary,
                                  salary_after_tax: salary_after_tax,
                                  base_salary: user.base_salary)

      user.users_benefits.each do |user_benefit|
        payroll.applied_benefits.build(users_benefit_id: user_benefit.id,
                                       amount: user_benefit.amount,
                                       benefit_id: user_benefit.benefit_id)
      end
      payroll.save!
      return payroll
    end
  rescue ActiveRecord::RecordInvalid
    payroll
  end

  def self.payroll_already_generated?(user)
    payroll = user.payrolls.reload.last
    return false unless payroll.present?

    date = payroll.created_at
    return true if DateTime.now.month == date.month && DateTime.now.year == date.year

    false
  end

  private

  def deliver_payroll_generation_email
    # Department#department_head returns nil when nobody in the department
    # holds that role, and an account owner has no department at all.
    department_head = user.department&.department_head
    return if department_head.nil?

    PayrollMailer.delay.payroll_generation(department_head.id, user.id, user.company.id)
  end
end
