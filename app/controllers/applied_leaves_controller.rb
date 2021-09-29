class AppliedLeavesController < ApplicationController
  before_action :authenticate_user!
  load_resource :user, id_param: :member_id, only: %i[index new create edit update destroy]
  load_resource :applied_leave, through: :user, only: %i[index new create edit update destroy]
  load_resource :applied_leave, only: %i[approve_leave reject_leave]
  load_resource :applied_leave, through: :current_company, only: :all_applied_leaves
  before_action :set_available_leaves, only: %i[new edit]
  authorize_resource
  add_breadcrumb I18n.t('applied_leave.breadcrumbs.home'), :member_applied_leaves_path, except: :all_applied_leaves

  # GET /members/:member_id/applied_leaves
  def index
    @applied_leaves = AppliedLeave.accessible_by(current_ability, :index).includes(:leave).paginate(page: params[:page],
                                                                                                    per_page: PAGE_SIZE)
    respond_to do |format|
      format.html
    end
  end

  # GET /members/:member_id/applied_leaves/new
  def new
    add_breadcrumb t('applied_leave.breadcrumbs.new'), :new_member_applied_leave_path
    respond_to do |format|
      format.html
    end
  end

  # POST /members/:member_id/applied_leaves
  def create
    if @applied_leave.validate_leave_year && (@applied_leave.set_leave && @applied_leave.leave_available?)
      is_saved = @applied_leave.save
    end
    respond_to do |format|
      format.html do
        if is_saved
          redirect_to member_applied_leaves_path,
                      notice: t('applied_leave.messages.leave_applied_success')
        else
          flash[:error] = @applied_leave.errors.full_messages
          redirect_to new_member_applied_leave_path(@user)
        end
      end
    end
  end

  # GET /members/:member_id/applied_leaves/:id/edit
  def edit
    add_breadcrumb t('applied_leave.breadcrumbs.edit'), :edit_member_applied_leave_path
    respond_to do |format|
      format.html
    end
  end

  # PATCH /members/:member_id/applied_leaves/:id
  def update
    if @applied_leave.validate_leave_year && @applied_leave.leave_available?
      is_updated = @applied_leave.update(applied_leave_params)
    end
    respond_to do |format|
      format.html do
        if is_updated
          redirect_to member_applied_leaves_path(@user),
                      notice: t('applied_leave.messages.leave_update_success')
        else

          flash[:error] = @leave.errors.full_messages
          redirect_to edit_member_applied_leave_path(@user, @applied_leave)
        end
      end
    end
  end

  # GET /members/get_available_user_leaves
  def get_available_user_leaves
    @user = current_company.users.find_by(id: params[:member_id])
    @available_user_leaves = @user.user_leaves.joins(:leave).select('user_leaves.id, leaves.name').where(
      'remaining_count > ?', 0
    )
    respond_to do |format|
      format.json do
        render json: @available_user_leaves
      end
    end
  end

  # DELETE /members/:member_id/applied_leaves/:id
  def destroy
    @applied_leave.destroy
    respond_to do |format|
      format.html do
        if @applied_leave.destroyed?
          flash[:notice] = t('applied_leave.messages.leave_delete_success')
        else
          flash[:error] = @applied_leave.errors.full_messages
        end
        redirect_to member_applied_leaves_path(@user)
      end
    end
  end

  # GET /applied_leaves/all_applied_leaves
  def all_applied_leaves
    add_breadcrumb t('applied_leave.breadcrumbs.new'), :all_applied_leaves_path
    get_filtered_records
    respond_to do |format|
      format.html
      format.js
    end
  end

  # PATCH /applied_leaves/:id/approve_leave
  def approve_leave
    is_approved = @applied_leave.approve_applied_leave
    respond_to do |format|
      format.html do
        if is_approved
          flash[:notice] = t('applied_leave.messages.leave_approve_success')
        else
          flash[:error] = @applied_leave.errors.full_messages
        end
        redirect_to all_applied_leaves_path
      end
    end
  end

  # PATCH /applied_leaves/:id/reject_leave
  def reject_leave
    is_rejected = @applied_leave.reject_applied_leave
    respond_to do |format|
      format.html do
        if is_rejected
          flash[:notice] = t('applied_leave.messages.leave_reject_success')
        else
          flash[:error] = @applied_leave.errors.full_messages
        end
        redirect_to all_applied_leaves_path
      end
    end
  end

  # PATCH /applied_leaves/approve_leaves
  def approve_leaves
    count_approved = AppliedLeave.approve_mass_leaves(params[:applied_leave_ids])
    get_filtered_records
    respond_to do |format|
      format.js do
        flash.now[:notice] =
          t('applied_leave.messages.mass_approve', total: total_request_count, actual: count_approved)
      end
    end
  end

  # PATCH /applied_leaves/reject_leaves
  def reject_leaves
    count_rejected = AppliedLeave.reject_mass_leaves(params[:applied_leave_ids])
    get_filtered_records
    respond_to do |format|
      format.js do
        flash.now[:notice] = t('applied_leave.messages.mass_reject', total: total_request_count, actual: count_rejected)
        render 'approve_leaves'
      end
    end
  end

  # GET /applied_leaves/filter_applied_leaves
  def filter_applied_leaves
    get_filtered_records
    respond_to do |format|
      format.js { render 'approve_leaves' }
    end
  end

  # GET /applied_leaves/new_applied_leave_by_hr
  def new_applied_leave_by_hr
    respond_to do |format|
      format.html
    end
  end

  # POST /applied_leaves/create_applied_leave_by_hr
  def create_applied_leave_by_hr
    @user = current_company.users.find_by(id: params[:applied_leave][:member_id])
    @applied_leave = @user.applied_leaves.build(applied_leave_params)
    if @applied_leave.validate_leave_year
      is_saved = @applied_leave.approve_hr_added_leave
    end
    respond_to do |format|
      format.html do
        if is_saved
          flash[:notice] = t('applied_leave.messages.leave_applied_success')
        else
          flash[:error] = @applied_leave.errors.full_messages
        end
        redirect_to all_applied_leaves_path
      end
    end
  end

  # GET /applied_leaves/search_users
  def search_users
    @users = current_company.users.where('email LIKE?', "#{params[:query]}%")
    respond_to do |format|
      format.json do
        render json: @users
      end
    end
  end

  private

  def total_request_count
    return params[:applied_leave_ids].size if params[:applied_leave_ids]

    0
  end

  def set_available_leaves
    @available_user_leaves = @user.get_available_leaves
  end

  def get_filtered_records
    @applied_leaves = AppliedLeave.get_filtered_records(params[:filter_type].to_s.downcase)
    @applied_leaves = @applied_leaves.includes(:user_leave, :user, :leave).paginate(page: params[:page],
                                                                                    per_page: PAGE_SIZE)
  end

  def applied_leave_params
    params.require(:applied_leave).permit(:user_leave_id, :applied_from, :applied_till, :leave_duration_type)
  end
end
