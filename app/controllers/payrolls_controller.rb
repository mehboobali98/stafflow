# frozen_string_literal: true

class PayrollsController < ApplicationController
  # GET /payrolls
  def index
    @user_benefits = UserBenefit.includes(:benefit).includes(:user)
    payroll_id = Payroll.generates_payroll_and_returns_id_of_generated_object(@user_benefits)
    Payroll.generate_applied_benefits(@user_benefits, payroll_id)
    @payroll = Payroll.includes(:user).last
    respond_to do |format|
      format.html
    end
  end
end
