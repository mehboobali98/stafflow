# frozen_string_literal: true

class PayrollsController < ApplicationController
  def index
    @payroll = Payroll.includes(:user).last
    @user_benefit = UserBenefit.includes(:benefit)
    @gross_salary = Payroll.calculate_gross_salary(@user_benefit, @payroll)
  end

  def create
    puts
  end
end
