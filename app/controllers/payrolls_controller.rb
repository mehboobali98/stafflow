# frozen_string_literal: true

class PayrollsController < ApplicationController
  # GET /payrolls
  def index
    @user = User.find_by_id(params[:member_id])
    @payroll = Payroll.joins(:user).last
    @applied_benefits = AppliedBenefit.where('applied_benefits.payroll_id = ?', @payroll.id)
    respond_to do |format|
      format.html
    end
  end

  def create
    @user = User.find_by_id(params[:member_id])
    @user_benefits = UserBenefit.joins(:user).includes(:benefit)
    if Payroll.check_last_payroll_date(Payroll.joins(:user).last.created_at)
      flash[:notice] = t('payroll.messages.success.create')
      @payroll = Payroll.generates_payroll_object_and_applied_benefits(@user_benefits, @user)
    else
      flash[:alert] = t('payroll.messages.failure.created_already')
    end
    respond_to do |format|
      format.html { redirect_to member_payrolls_path }
    end
  end
end
