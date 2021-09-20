class UsersBenefitsController < ApplicationController
  before_action :load_users_benefit, only: %i[destroy update show]
  before_action :load_users_benefits, only: %i[new create]
  before_action :load_benefits, only: %i[new create]
  before_action :load_user

  # GET members/:id/users_benefits
  def index
    @users_benefits = @user.users_benefits.includes(:benefit)
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
    create_users_benefit_objects
    flash[:notice] = @notice
    flash[:errors] = @errors
    respond_to do |format|
      format.html { redirect_to member_users_benefits_path }
    end
  end

  # DELETE members/:id/users_benefits/:id
  def destroy
    @users_benefit.destroy
    respond_to do |format|
      if @users_benefit.destroyed?
        flash[:notice] = t('users_benefit.messages.success.delete')
      else
        flash[:error] =  @users_benefit.errors.full_messages
      end
      format.html { redirect_to member_users_benefits_path }
    end
  end

  # PATCH/PUT members/:id/users_benefits/:id
  def update
    is_updated = @users_benefit.update(update_user_benefit_params)
    respond_to do |format|
      if is_updated
        format.html { redirect_to member_users_benefits_path, notice: t('users_benefit.messages.success.update') }
      else
        format.html { redirect_to member_users_benefits_path, alert: @users_benefit.errors.full_messages }
      end
    end
  end

  private

  def update_user_benefit_params
    params.require(:users_benefit).permit(:amount, :status)
  end

  def load_users_benefit
    @users_benefit = UsersBenefit.find_by(sequence_num: params[:id])
  end

  def load_users_benefits
    @users_benefits = UsersBenefit.includes(:benefit).all
  end

  def load_benefits
    @benefits = Benefit.all
  end

  def load_user
    @user = User.find_by_id(params[:member_id])
  end

  def create_users_benefit_objects
    params[:users_benefit].each do |id, amount|
      user_benefit = UsersBenefit.new(amount: amount,
                                      benefit_id: id,
                                      user_id: @user.id)
      user_benefit.save!
      @notice ||= []
      @notice << t('users_benefit.messages.success.create', benefit_name: user_benefit.benefit.name)
    rescue ActiveRecord::RecordInvalid
      @errors ||= []
      @errors << new_user_benefit.benefit.name + ' ' + new_users_benefit.errors.full_messages.first
    end
  end
end
