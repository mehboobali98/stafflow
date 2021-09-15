class AppliedLeavesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_applied_leave, only: %i[show edit update destroy approve_leave reject_leave]

  # GET    /applied_leaves
  def index
    @applied_leaves = AppliedLeave.joins(:user_leave).where(user_leaves: { user_id: current_user.id })
    respond_to do |format|
      format.html
    end
  end

  # GET    /applied_leaves/new
  def new
    @user_leaves = UserLeave.get_user_leaves(current_user.id)
    @applied_leave = AppliedLeave.new
    respond_to do |format|
      format.html
    end
  end

  # POST   /applied_leaves
  def create
    @applied_leave = AppliedLeave.new(applied_leave_params)
    is_saved = @applied_leave.save if @applied_leave.validate_leave_year && @applied_leave.leave_count_available?
    respond_to do |format|
      format.html do
        return redirect_to applied_leaves_path, notice: t('applied_leave.messages.leave_applied_success') if is_saved

        flash.now[:error] = @applied_leave.errors.full_messages
        @user_leaves = UserLeave.get_user_leaves(current_user.id)
        render :new
      end
    end
  end

  # GET    /applied_leaves/:id/edit
  def edit
    @user_leaves = UserLeave.get_user_leaves(current_user.id)
  end

  # PATCH/PUT  /applied_leaves/:id
  def update
    is_updated = @applied_leave.update(applied_leave_params)
    respond_to do |format|
      format.html do
        return redirect_to leaves_path, notice: t('applied_leave.messages.leave_update_success') if is_updated

        flash.now[:error] = @leave.errors.full_messages
        @user_leaves = UserLeave.get_user_leaves(current_user.id)
        render :edit
      end
    end
  end

  # DELETE /applied_leaves/:id
  def destroy
    @applied_leave.destroy
    is_destroyed = @applied_leave.destroyed?
    respond_to do |format|
      format.html do
        flash[:error] = @applied_leave.errors.full_messages unless is_destroyed
        flash[:notice] = t('applied_leave.messages.leave_delete_success')
        redirect_to applied_leaves_path
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
    binding.pry
    is_saved = @applied_leave.approve_applied_leave
    respond_to do |format|
      format.html do
        flash[:notice] = t('applied_leave.messages.leave_approve_success') if is_saved
        flash.now[:error] = @applied_leave.errors.full_messages
        return redirect_to show_applied_leaves_path
      end
    end
  end

  # PATCH  /applied_leaves/:id/reject_leave
  def reject_leave
    is_saved = @applied_leave.reject_applied_leave
    respond_to do |format|
      format.html do
        flash[:notice] = t('applied_leave.messages.leave_reject_success') if is_saved
        flash[:error] = @applied_leave.errors
                                      .return redirect_to show_applied_leaves_path
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

  def set_applied_leave
    @applied_leave = AppliedLeave.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = e.message
    redirect_to applied_leaves_path
  end

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
    params.require(:filter_type).permit(:filter_type)
  end
end
