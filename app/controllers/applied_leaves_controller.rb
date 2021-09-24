class AppliedLeavesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :user, id_param: :member_id, only: %i[index new create edit update destroy]
  load_and_authorize_resource :applied_leave, through: :user, only: %i[index edit update destroy]
  load_resource :applied_leave, only: %i[approve_leave reject_leave]
  load_resource :applied_leave, through: :current_company, only: :all_applied_leaves
  before_action :set_available_leaves, only: %i[new edit]
  authorize_resource

  # GET /members/:member_id/applied_leaves
  def index
    @applied_leaves.includes(:leave)
    respond_to do |format|
      format.html
    end
  end

  # GET /members/:member_id/applied_leaves/new
  def new
    @applied_leave = AppliedLeave.new
    respond_to do |format|
      format.html
    end
  end

  # POST /applied_leaves/add_user_leave
  def add_user_leave_by_hr
    @user = User.find(params[:applied_leave][:member_id])
    @applied_leave = @user.applied_leaves.build(applied_leave_params)
    @applied_leave.set_leave
    @applied_leave.save
    @applied_leave.approve_applied_leave
    redirect_to all_applied_leaves_path
  end

  # POST /applied_leaves/get_user_leaves
  def get_user_leaves
    @user = User.find(params[:user][:member_id])
    @user_leaves = @user.user_leaves.joins(:leave).select('user_leaves.id, leaves.name').where('remaining_count > ?', 0)
    respond_to do |format|
      format.json do
        render json: @user_leaves
      end
    end
  end

  # GET /applied_leaves/get_users_list
  def get_users_list
    @users = User.where("email LIKE?", "#{params[:user][:email]}%")
    respond_to do |format|
      format.json do
        render json: @users
      end
    end
  end

  # GET /applied_leaves/show_users_list
  def show_users_list
    respond_to do |format|
      format.html
    end
  end

  # POST /members/:member_id/applied_leaves
  def create
    @applied_leave = @user.applied_leaves.build(applied_leave_params)
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
    respond_to do |format|
      format.html
    end
  end

  # PATCH /members/:member_id/applied_leaves/:id
  def update
    is_updated = @applied_leave.update(applied_leave_params)
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
    @applied_leaves.includes(user_leave: %i[user leave])
    respond_to do |format|
      format.html
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
    @applied_leaves.includes(user_leave: %i[user leave])
  end

  def applied_leave_params
    params.require(:applied_leave).permit(:user_leave_id, :applied_from, :applied_till, :leave_duration_type)
  end
end
