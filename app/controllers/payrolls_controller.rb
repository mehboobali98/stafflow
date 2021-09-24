# frozen_string_literal: true

class PayrollsController < ApplicationController
  load_and_authorize_resource :user, id_param: :member_id
  load_and_authorize_resource through: :user, find_by: :sequence_num
  before_action :payroll_validation, only: :create
  add_breadcrumb I18n.t('payroll.breadcrumbs.home'), :member_payrolls_path

  # GET members/:id/payrolls
  def index
    @payrolls = @payrolls.paginate(page: params[:page], per_page: PAGE_SIZE) if @payrolls
    respond_to do |format|
      format.html
    end
  end

  # GET members/:id/payrolls/:id
  def show
    add_breadcrumb @payroll.sequence_num, :member_payroll_path
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

  def payroll_validation
    return unless Payroll.payroll_already_generated?(@user)

    flash[:alert] = t('payroll.messages.failure.created_already')
    redirect_to member_payrolls_path
  end
end
