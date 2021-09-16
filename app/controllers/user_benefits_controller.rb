class UserBenefitsController < ApplicationController
  before_action :load_user_benefit, only: %i[destroy update show]
  before_action :load_user_benefits, only: %i[new create]
  before_action :load_benefits, only: %i[new create]
  before_action :load_user

  # GET members/:id/user_benefits
  def index
    @user = User.find_by_id(params['member_id'])
    @user_benefits = UserBenefit.where('user_benefits.user_id = ?', @user.id).includes(:benefit)
    respond_to do |format|
      format.html
    end
  end

  # GET members/:id/user_benefits/new
  def new
    respond_to do |format|
      format.html
    end
  end

  # GET members/:id/user_benefits/:id
  def show
    respond_to do |format|
      format.html
    end
  end

  # POST members/:id/user_benefits
  def create
    # this function is to refactored, using jquery
    user_benefit_objects = UserBenefit.initialze_user_benefits(params, @user.id)
    user_benefit_objects.each do |new_user_benefit|
      new_user_benefit.save!
      flash[:notice] ||= []
      flash[:notice] << new_user_benefit.benefit.name + ' ' + t('user_benefit.messages.success.create')
    rescue ActiveRecord::RecordInvalid
      flash[:errors] ||= []
      flash[:errors] << (new_user_benefit.benefit.name + ' ' + new_user_benefit.errors.full_messages.first)
    end
    respond_to do |format|
      format.html { redirect_to member_user_benefits_path }
    end
  end

  # DELETE members/:id/user_benefits/:id
  def destroy
    is_destroyed = @user_benefit.destroy
    respond_to do |format|
      if is_destroyed
        flash[:notice] = t('user_benefit.messages.success.delete')
      else
        flash[:error] =  @user_benefit.errors.full_messages
      end
      format.html { redirect_to member_user_benefits_path }
    end
  end

  # PATCH/PUT members/:id/user_benefits/:id
  def update
    is_updated = @user_benefit.update(permitted_user_benefit_arguments_for_update)
    respond_to do |format|
      if is_updated
        format.html { redirect_to member_user_benefits_path, notice: t('user_benefit.messages.success.update') }
      else
        format.html { redirect_to member_user_benefits_path, alert: @user_benefit.errors.full_messages }
      end
    end
  end

  private

  def permitted_user_benefit_arguments_for_create
    params.require(:user_benefit).permit(benefit_id[], amount[])
  end

  def permitted_user_benefit_arguments_for_update
    params.require(:user_benefit).permit(:amount, :status)
  end

  def load_user_benefit
    @user_benefit = UserBenefit.find_by_sequence_num!(params[:id])
  end

  def load_user_benefits
    @user_benefits = UserBenefit.includes(:benefit).all
  end

  def load_benefits
    @benefits = Benefit.all
  end

  def load_user
    @user = User.find_by_id(params[:member_id])
  end
end
