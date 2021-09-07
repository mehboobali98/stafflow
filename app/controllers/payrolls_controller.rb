# frozen_string_literal: true

class PayrollsController < ApplicationController
  # GET /payrolls
  def index
    @user_benefit = UserBenefit.includes(:benefit).includes(:user)
    payroll_id = Payroll.generate_payroll(@user_benefit)
    Payroll.generate_applied_benefits(@user_benefit, payroll_id)
    @payroll = Payroll.includes(:user).last
  end
end
