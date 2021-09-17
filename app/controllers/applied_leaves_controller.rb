class AppliedLeavesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[index new create edit update destroy]
  before_action :set_applied_leave, only: %i[show edit update destroy approve_leave reject_leave]

  # GET    /members/:member_id/applied_leaves
  def index
    @applied_leaves = @user.applied_leaves
    respond_to do |format|
      format.html
    end
  end

  # GET    /members/:member_id/applied_leaves/new
  def new
    @user_leaves = UserLeave.get_user_leaves(@user.id)
    @applied_leave = AppliedLeave.new
    respond_to do |format|
      format.html
    end
  end

  # POST   /members/:member_id/applied_leaves
  def create
    @applied_leave = AppliedLeave.new(applied_leave_params)
    @applied_leave.user_id = @user.id
    @applied_leave.leave_id = @user.user_leaves.where(id: applied_leave_params[:user_leave_id]).pluck(:leave_id).first
    is_saved = @applied_leave.save if @applied_leave.validate_leave_year && @applied_leave.leave_count_available?
    respond_to do |format|
      format.html do
        if is_saved
          redirect_to member_applied_leaves_path,
                      notice: t('applied_leave.messages.leave_applied_success')
        end

        flash.now[:error] = @applied_leave.errors.full_messages
        @user_leaves = UserLeave.get_user_leaves(@user.id)
        render :new
      end
    end
  end

  # GET    /members/:member_id/applied_leaves/:id/edit
  def edit
    @user_leaves = UserLeave.get_user_leaves(@user.id)
  end

  # PATCH  /members/:member_id/applied_leaves/:id
  def update
    is_updated = @applied_leave.update(applied_leave_params)
    respond_to do |format|
      format.html do
        if is_updated
          redirect_to member_applied_leaves_path(@user),
                      notice: t('applied_leave.messages.leave_update_success')
        end

        flash.now[:error] = @leave.errors.full_messages
        @user_leaves = UserLeave.get_user_leaves(current_user.id)
        render :edit
      end
    end
  end

  # DELETE /members/:member_id/applied_leaves/:id
  def destroy
    @applied_leave.destroy
    is_destroyed = @applied_leave.destroyed?
    respond_to do |format|
      format.html do
        flash[:error] = @applied_leave.errors.full_messages unless is_destroyed
        flash[:notice] = t('applied_leave.messages.leave_delete_success')
        redirect_to member_applied_leaves_path(@user)
      end
    end
  end

  # GET    /applied_leaves/show_applied_leaves
  def show_applied_leaves
    @applied_leaves = AppliedLeave.get_applied_leaves
    respond_to do |format|
      format.html
    end
  end

  # PATCH  /applied_leaves/:id/approve_leave
  def approve_leave
    is_saved = @applied_leave.approve_applied_leave
    respond_to do |format|
      format.html do
        flash[:notice] = t('applied_leave.messages.leave_approve_success') if is_saved
        flash[:error] = t('applied_leave.messages.leave_approve_failure')
        redirect_to show_applied_leaves_path
      end
    end
  end

  # PATCH  /applied_leaves/:id/reject_leave
  def reject_leave
    is_saved = @applied_leave.reject_applied_leave
    respond_to do |format|
      format.html do
        flash[:notice] = t('applied_leave.messages.leave_reject_success') if is_saved
        flash[:error] = t('applied_leave.messages.leave_reject_failure')
        return redirect_to show_applied_leaves_path
      end
    end
  end

  # PATCH  /applied_leaves/approve_multiple_leaves
  def approve_multiple_leaves
    AppliedLeave.approve_multiple_applied_leaves(multiple_leave_params)
    get_filtered_records
    respond_to do |format|
      format.js
    end
  end

  # PATCH  /applied_leaves/reject_multiple_leaves
  def reject_multiple_leaves
    AppliedLeave.reject_multiple_applied_leaves(multiple_leave_params)
    get_filtered_records
    respond_to do |format|
      format.js
    end
  end

  # GET    /applied_leaves/filter_applied_leaves
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
    params.require(:applied_leave).permit(:user_leave_id, :applied_at, :applied_till, :leave_duration_id)
  end

  def multiple_leave_params
    params.require(:applied_leave_ids)
  end

  def filter_params
    params.require(:filterType).permit(:filter_type)
  end

  def user_params
    params.require(:member_id)
  end

  def set_user
    @user = User.find(user_params)
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = e.message
    redirect_to members_path
  end

  def set_applied_leave
    @applied_leave = AppliedLeave.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = e.message
    redirect_to member_applied_leaves_path(@user)
  end
end
