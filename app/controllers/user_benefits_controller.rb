class UserBenefitsController < ApplicationController
  before_action :load_users_benefit, only: %i[destroy update show]
  before_action :load_users_benefits, only: %i[new create]
  before_action :load_benefits, only: %i[new create]
  before_action :load_user

  # GET members/:id/users_benefits
  def index
    @user = User.find_by_id(params['member_id'])
    @users_benefits = UserBenefit.includes(:user).includes(:benefit)
    respond_to do |format|
      format.html
    end
  end

  # GET members/:id/users_benefits/new
  def new
    respond_to do |format|
      format.html
    end
  end

  # GET members/:id/users_benefits/:id
  def show
    respond_to do |format|
      format.html
    end
  end

  # POST members/:id/users_benefits
  def create
    # this function is to refactored, using jquery
    users_benefit_objects = UserBenefit.initialze_users_benefits(params, @user.id)
    users_benefit_objects.each do |new_users_benefit|
      new_users_benefit.save!
      flash[:notice] ||= []
      flash[:notice] << new_users_benefit.benefit.name + ' ' + t('users_benefit.messages.success.create')
    rescue ActiveRecord::RecordInvalid
      flash[:errors] ||= []
      flash[:errors] << (new_users_benefit.benefit.name + ' ' + new_users_benefit.errors.full_messages.first)
    end
    respond_to do |format|
      format.html { redirect_to member_users_benefits_path }
    end
  end

  # DELETE members/:id/users_benefits/:id
  def destroy
    is_destroyed = @users_benefit.destroy
    respond_to do |format|
      if is_destroyed
        flash[:notice] = t('users_benefit.messages.success.delete')
      else
        flash[:error] =  @users_benefit.errors.full_messages
      end
      format.html { redirect_to member_users_benefits_path }
    end
  end

  # PATCH/PUT members/:id/users_benefits/:id
  def update
    is_updated = @users_benefit.update(permitted_users_benefit_arguments_for_update)
    respond_to do |format|
      if is_updated
        format.html { redirect_to member_users_benefits_path, notice: t('users_benefit.messages.success.update') }
      else
        format.html { redirect_to member_users_benefits_path, alert: @users_benefit.errors.full_messages }
      end
    end
  end

  private

  def permitted_users_benefit_arguments_for_create
    params.require(:users_benefit).permit(benefit_id[], amount[])
  end

  def permitted_users_benefit_arguments_for_update
    params.require(:users_benefit).permit(:amount, :status)
  end

  def load_users_benefit
    @users_benefit = UserBenefit.find_by_sequence_num!(params[:id])
  end

  def load_users_benefits
    @users_benefits = UserBenefit.includes(:benefit).all
  end

  def load_benefits
    @benefits = Benefit.all
  end

  def load_user
    @user = User.find_by_id(params[:member_id])
  end
end
