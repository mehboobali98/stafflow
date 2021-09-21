class UsersBenefitsController < ApplicationController
  before_action :load_user
  before_action :load_users_benefit, only: %i[destroy update show]
  before_action :load_users_benefits, only: %i[new create]

  # GET members/:id/users_benefits
  def index
    @users_benefits = @user.users_benefits.includes(:benefit)
    respond_to do |format|
      format.html
    end
  end

  # GET members/:id/users_benefits/new
  def new
    benefits_applied = @users_benefits.pluck('benefit_id')
    @benefits = Benefit.where.not(id: benefits_applied)
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
    benefits_applied = @users_benefits.pluck('benefit_id')
    @benefits = Benefit.where.not(id: benefits_applied)
    create_users_benefit_objects
    if @notice.present?
      flash[:notice] = @notice
    else
      flash[:errors] = @errors
    end
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
    @users_benefit = @user.users_benefits.find_by(sequence_num: params[:id])
  end

  def load_users_benefits
    @users_benefits = @user.users_benefits
  end

  def load_user
    @user = User.find_by(id: params[:member_id])
  end

  # params[user_benefit][benefit_id] : amount
  def create_users_benefit_objects
    params[:users_benefit].each do |benefit_id, amount|
      new_user_benefit = UsersBenefit.new(amount: amount,
                                          benefit_id: benefit_id,
                                          user_id: @user.id)
      new_user_benefit.save!
      @notice = []
      @notice << t('users_benefit.messages.success.create', benefit_name: new_user_benefit.benefit.name)
    rescue ActiveRecord::RecordInvalid
      @errors = []
      @errors << new_user_benefit.benefit.name + ' ' + new_user_benefit.errors.full_messages.first
    end
  end
end
