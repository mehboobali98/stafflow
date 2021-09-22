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
    @applied_benefits = @payroll.applied_benefits.includes(:benefit)
    respond_to do |format|
      format.html
    end
  end

  # POST members/:id/payrolls
  def create
    payroll = Payroll.generate_payroll(@user)
    respond_to do |format|
      if payroll
        flash[:notice] = t('payroll.messages.success.create')
        format.html { redirect_to member_payroll_path(@user, payroll) }
      else
        flash[:alert] = payroll.errors.full_messages.first
        format.html { redirect_to members_payroll_path }
      end
    end
  end

  protected

  def payroll_validation
    if Payroll.payroll_already_generated?(@user)
      flash[:alert] = t('payroll.messages.failure.created_already')
      redirect_to member_payrolls_path
    end
  end
end
