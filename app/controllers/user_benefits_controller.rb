class UserBenefitsController < ApplicationController
  before_action :load_user_benefit_object, only: %i[destroy update show]
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
    loop_iterator = 0
    params['user_benefit']['amount'].each do |amount|
      next if amount == ''

      new_user_benefit = UserBenefit.new(amount: amount,
                                         status: params['user_benefit']['status'][loop_iterator],
                                         benefit_id: params['user_benefit']['benefit_id'][loop_iterator],
                                         user_id: 1)
      loop_iterator += 1
      begin
        new_user_benefit.save!
        flash[:notice] = t('user_benefit.messages.success.')
      rescue ActiveRecord::RecordInvalid
        flash[:errors] = new_user_benefit.errors.full_messages
      end
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
        format.html { redirect_to user_benefits_path, notice: t('user_benefit.messages.success.updated') }
      else
        format.html { redirect_to user_benefits_path, alert: @user_benefit.errors.full_messages }
      end
    end
  end

  def permitted_user_benefit_arguments_for_create
    params.require(:user_benefit).permit(benefit_id[], amount[], status[])
  end

  def permitted_user_benefit_arguments_for_update
    params.require(:user_benefit).permit(:amount, :status)
  end

  private

  def load_user_benefit_object
    @user_benefit = UserBenefit.find(params[:id])
  end

  def load_user_benefits_and_benefits
    @benefits = Benefit.all
    @user_benefits = UserBenefit.includes(:benefit).all
  end
end
