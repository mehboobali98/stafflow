class AppliedLeavesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_applied_leave, only: %i[show edit update destroy approve_leave]
  def index
    @applied_leaves = AppliedLeave.joins(:user_leave).where(user_leaves: { user_id: current_user.id })
    respond_to do |format|
      format.html
    end
  end

  def show
    respond_to do |format|
      format.html
    end
  end

  def new
    @user_leaves = UserLeave.joins(:leave).select('user_leaves.id, leaves.name').where(
      'user_id = ? AND remaining_count > ?', current_user.id, 0
    )
    @applied_leave = AppliedLeave.new
    respond_to do |format|
      format.html
    end
  end

  def create
    @applied_leave = AppliedLeave.new(applied_leave_params)
    binding.pry
    is_saved = @applied_leave.save if @applied_leave.leave_count_available?
    binding.pry
    respond_to do |format|
      format.html do
        return redirect_to action: 'index', notice: 'Leave applied successfully' if is_saved

        flash.now[:error] = @applied_leave.errors.full_messages
        render :new
      end
    end
  end

  def edit; end

  def update; end

  def destroy
    @applied_leave.destroy
    is_destroyed = @applied_leave.destroyed?
    respond_to do |format|
      format.html do
        flash[:error] = @applied_leave.errors.full_messages unless is_destroyed
        flash[:notice] = 'Leave destroyed successfully'
        redirect_to events_path
      end
    end
  end

  def display_pending_leaves
    @applied_leaves = AppliedLeave.where(state: 'pending')
    respond_to do |format|
      format.html
    end
  end

  # POST   /applied_leaves/:id/approve_leave
  def approve_leave
    is_saved = @applied_leave.approve_applied_leave
    binding.pry
    respond_to do |format|
      format.html do
        return redirect_to action: 'display_pending_leaves', notice: 'Leave approved successfully' if is_saved

        flash.now[:error] = @applied_leave.errors.full_messages
        render :display_pending_leaves
      end
    end
  end

  # POST   /applied_leaves/:id/reject_leave
  def reject_leave
    return unless @applied_leave.state.eql?('pending')

    @applied_leave.request_rejected
    is_saved = @applied_leave.save
    respond_to do |format|
      format.html do
        return redirect_to action: 'display_pending_leaves', notice: 'Leave rejected successfully' if is_saved

        flash.now[:error] = @applied_leave.errors.full_messages
        render :display_pending_leaves
      end
    end
  end

  private

  def set_applied_leave
    @applied_leave = AppliedLeave.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = e.message
    redirect_to applied_leaves_path
  end

  def applied_leave_params
    params.require(:applied_leave).permit(:user_leave_id, :applied_at, :applied_till, :leave_duration_id)
  end
end
