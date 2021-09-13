class UserBenefitsController < ApplicationController
  before_action :load_user_benefit, only: %i[destroy update show]
  before_action :load_user_benefits_and_benefits, only: %i[new create]

  # GET /user_benefits
  def index
    @user_benefits = UserBenefit.includes(:user)
    respond_to do |format|
      format.html
    end
  end

  # GET /user_benefits/new
  def new
    respond_to do |format|
      format.html
    end
  end

  # POST /user_benefits
  def create
    # this function is to refactored, using jquery
    user_benefit_objects = UserBenefit.initialze_user_benefits(params)
    user_benefit_objects.each do |new_user_benefit|
      new_user_benefit.save!
      flash[:notice] = t('user_benefit.messages.success.')
    rescue ActiveRecord::RecordInvalid
      flash[:errors] = new_user_benefit.errors.full_messages
    end
    respond_to do |format|
      format.html { redirect_to action: 'index' }
    end
  end

  # GET /user_benefits/:id
  def show
    respond_to do |format|
      format.html
    end
  end

  # DELETE /user_benefits/:id
  def destroy
    is_destroyed = @user_benefit.destroy
    respond_to do |format|
      if is_destroyed
        format.html { redirect_to user_benefits_path, notice: t('user_benefit.messages.success.delete') }
      else
        format.html { redirect_to user_benefits_path, alert: @user_benefit.errors.full_messages }
      end
    end
  end

  # PATCH/PUT /user_benefits/:id
  def update
    is_updated = @user_benefit.update(permitted_user_benefit_arguments_for_update)
    respond_to do |format|
      if is_updated
        format.html { redirect_to user_benefits_path, notice: t('user_benefit.messages.success.update') }
      else
        format.html { redirect_to user_benefits_path, alert: @user_benefit.errors.full_messages }
      end
    end
  end

  def permitted_user_benefit_arguments_for_create
    params.require(:user_benefit).permit(benefit_id[], amount[])
  end

  def permitted_user_benefit_arguments_for_update
    params.require(:user_benefit).permit(:amount, :status)
  end

  private

  def load_user_benefit
    @user_benefit = UserBenefit.find_by_sequence_num!(params[:id])
  end

  def load_user_benefits_and_benefits
    @benefits = Benefit.all
    @user_benefits = UserBenefit.includes(:benefit).all
  end
end
