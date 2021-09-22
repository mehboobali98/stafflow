# frozen_string_literal: true

class PayrollsController < ApplicationController
  load_and_authorize_resource

  # GET members/:id/payrolls
  def index
    respond_to do |format|
      format.html
    end
  end

  # GET members/:id/payrolls/:id
  def show
    @applied_benefits = @payroll.applied_benefits
    respond_to do |format|
      format.html
    end
  end

  # POST members/:id/payrolls
  def create
    payroll = Payroll.generate_payroll(@user)
    if payroll.persisted?
      flash[:notice] = t('payroll.messages.success.create')
    else
      flash[:alert] = payroll.errors.full_messages.first
      format.html { redirect_to members_payroll_path }
    end
    respond_to do |format|
      format.html { redirect_to member_payroll_path(@user, payroll) }
    end
  end

  protected

  def check_payroll_creation
    if Payroll.check_last_payroll_date(@user)
      flash[:alert] = t('payroll.messages.failure.created_already')
      redirect_to member_payrolls_path
    end
  end
end
