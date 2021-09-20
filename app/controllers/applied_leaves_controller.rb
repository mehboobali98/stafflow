class AppliedLeavesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[index new create edit update destroy]
  before_action :set_applied_leave, only: %i[show edit update destroy approve_leave reject_leave]

  # GET /members/:member_id/applied_leaves
  def index
    @applied_leaves = @user.applied_leaves.includes(:leave)
    respond_to do |format|
      format.html
    end
  end

  # GET /members/:member_id/applied_leaves/new
  def new
    @user_leaves = @user.user_leaves.joins(:leave).select('user_leaves.id, leaves.name').where('remaining_count > ?', 0)
    @applied_leave = AppliedLeave.new
    respond_to do |format|
      format.html
    end
  end

  def add_user_leave
    @user = User.find(params[:applied_leave][:member_id])
    @applied_leave = @user.applied_leaves.build(applied_leave_params)
    @applied_leave.leave_id = UserLeave.find_by(id: applied_leave_params[:user_leave_id]).leave.id
    @applied_leave.save
    @applied_leave.approve_applied_leave
    redirect_to show_applied_leaves_path
  end

  def get_user_leaves
    @user = User.find(params[:user][:member_id])
    @user_leaves = @user.user_leaves.joins(:leave).select('user_leaves.id, leaves.name').where('remaining_count > ?', 0)
    respond_to do |format|
      format.json do
        render json: @user_leaves
      end
    end
  end

  def get_users_list
    @users = User.where("email LIKE?", "#{params[:user][:email]}%")
    respond_to do |format|
      format.json do
        render json: @users
      end
    end
  end

  def show_users_list
    @users = User.all
  end

  # POST /members/:member_id/applied_leaves
  def create
    @applied_leave = @user.applied_leaves.build(applied_leave_params)
    @applied_leave.leave_id = UserLeave.find_by(id: applied_leave_params[:user_leave_id]).leave.id
    is_saved = @applied_leave.save if @applied_leave.validate_leave_year && @applied_leave.leave_count_available?
    respond_to do |format|
      format.html do
        if is_saved
          redirect_to member_applied_leaves_path,
                      notice: t('applied_leave.messages.leave_applied_success')
        else
          flash.now[:error] = @applied_leave.errors.full_messages
          @user_leaves = @user.user_leaves.joins(:leave).select('user_leaves.id, leaves.name').where(
            'remaining_count > ?', 0
          )
          render :new
        end
      end
    end
  end

  # GET /members/:member_id/applied_leaves/:id/edit
  def edit
    @user_leaves = @user.user_leaves.joins(:leave).select('user_leaves.id, leaves.name').where('remaining_count > ?', 0)
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

          flash.now[:error] = @leave.errors.full_messages
          @user_leaves = @user.user_leaves.joins(:leave).select('user_leaves.id, leaves.name').where(
            'remaining_count > ?', 0
          )
          render :edit
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

  # GET /applied_leaves/show_applied_leaves
  def show_applied_leaves
    @applied_leaves = AppliedLeave.get_applied_leaves
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
          flash[:error] = t('applied_leave.messages.leave_approve_failure')
        end
        redirect_to show_applied_leaves_path
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
          flash[:error] = t('applied_leave.messages.leave_reject_failure')
        end
        redirect_to show_applied_leaves_path
      end
    end
  end

  # PATCH /applied_leaves/approve_multiple_leaves
  def approve_multiple_leaves
    AppliedLeave.approve_multiple_applied_leaves(multiple_leave_params)
    get_filtered_records
    respond_to do |format|
      format.js
    end
  end

  # PATCH /applied_leaves/reject_multiple_leaves
  def reject_multiple_leaves
    AppliedLeave.reject_multiple_applied_leaves(multiple_leave_params)
    get_filtered_records
    respond_to do |format|
      format.js
    end
  end

  # GET /applied_leaves/filter_applied_leaves
  def filter_applied_leaves
    get_filtered_records
    respond_to do |format|
      format.js
    end
  end

  private

  def get_filtered_records
    @applied_leaves = AppliedLeave.get_filtered_records(filter_params[:filter_type].downcase)
  end

  def applied_leave_params
    params.require(:applied_leave).permit(:user_leave_id, :applied_from, :applied_till, :leave_duration_id)
  end

  def multiple_leave_params
    params.require(:applied_leave_ids)
  end

  def filter_params
    params.require(:filterType).permit(:filter_type)
  end

  def set_user
    @user = User.find(params[:member_id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t('common.user_not_found')
    redirect_to members_path
  end

  def set_applied_leave
    @applied_leave = AppliedLeave.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t('applied_leave.messages.error.not_found')
    redirect_to member_applied_leaves_path(@user)
  end
end
