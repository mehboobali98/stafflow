# frozen_string_literal: true

class PayrollsController < ApplicationController
  before_action :load_user
  before_action :load_a_payroll, only: :show
  before_action :load_all_payrolls, only: :index

  # GET members/:id/payrolls
  def index
    respond_to do |format|
      format.html
    end
  end

  # GET members/:id/payrolls/:id
  def show
    @applied_benefits = AppliedBenefit.where('applied_benefits.payroll_id = ?', @payroll.id) if @payroll
    respond_to do |format|
      format.html
    end
  end

  # POST members/:id/payrolls
  def create
    @user_benefits = UserBenefit.joins(:user).includes(:benefit)
    if Payroll.exists?
      if Payroll.check_last_payroll_date(Payroll.joins(:user).last.created_at)
        flash[:notice] = t('payroll.messages.success.create')
        @payroll = Payroll.generates_payroll_object_and_applied_benefits(@user_benefits, @user)
      else
        flash[:alert] = t('payroll.messages.failure.created_already')
      end
    else
      Payroll.generates_payroll_object_and_applied_benefits(@user_benefits, @user)
    end
    respond_to do |format|
      format.html { redirect_to member_payrolls_path }
    end
  end

  private

  def load_user
    @user = User.find_by_id(params[:member_id])
  end

  def load_all_payrolls
    @payrolls = Payroll.joins(:user)
  end

  def load_a_payroll
    @payroll = Payroll.find_by_sequence_num!(params[:id])
  end
end
