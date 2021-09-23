class UsersBenefitsController < ApplicationController
  load_and_authorize_resource :user, id_param: :member_id
  load_and_authorize_resource through: :user, find_by: :sequence_num
  add_breadcrumb I18n.t('users_benefit.breadcrumbs.home'), :member_users_benefits_path

  # GET members/:id/users_benefits
  def index
    @users_benefits = @user.users_benefits.includes(:benefit).paginate(page: params[:page], per_page: PAGE_SIZE)
    respond_to do |format|
      format.html
    end
  end

  # GET members/:id/users_benefits/available_benefits
  def available_benefits
    add_breadcrumb t('users_benefit.breadcrumbs.new'), :available_benefits_member_users_benefits_path
    benefit_ids = @users_benefits.pluck('benefit_id')
    @available_benefits = Benefit.where.not(id: benefit_ids)
    respond_to do |format|
      format.html
    end
  end

  # POST members/:id/users_benefits/mass_create
  def mass_create
    create_users_benefit
    if @notice.present?
      flash[:notice] = @notice
    else
      flash[:errors] = @errors.first(5)
    end
    respond_to do |format|
      format.html { redirect_to member_users_benefits_path }
    end
  end

  # GET members/:id/users_benefits/:id/edit
  def edit
    add_breadcrumb t('users_benefit.breadcrumbs.edit'), :edit_member_users_benefit_path
    respond_to do |format|
      format.html
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

  private

  def update_user_benefit_params
    params.require(:users_benefit).permit(:amount)
  end

  # params[users_benefit][benefit_id] : amount
  # e.g params['users_benefit'][2] = 200
  def create_users_benefit
    @notice = []
    @errors = []
    params[:users_benefit].each do |benefit_id, amount|
      new_user_benefit = UsersBenefit.new(amount: amount,
                                          benefit_id: benefit_id,
                                          user_id: @user.id)
      new_user_benefit.save!
      @notice << t('users_benefit.messages.success.create', benefit_name: new_user_benefit.benefit.name)
    rescue ActiveRecord::RecordInvalid
      @errors << new_user_benefit.errors.full_messages
    end
  end
end
