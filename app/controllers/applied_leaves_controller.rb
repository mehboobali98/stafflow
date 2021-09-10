class AppliedLeavesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_applied_leave, only: %i[show edit update destroy approve_leave]

  # GET    /applied_leaves
  def index
    @applied_leaves = AppliedLeave.joins(:user_leave).where(user_leaves: { user_id: current_user.id })
    respond_to do |format|
      format.html
    end
  end

  # GET    /applied_leaves/:id
  def show
    respond_to do |format|
      format.html
    end
  end

  # GET    /applied_leaves/new
  def new
    @user_leaves = UserLeave.joins(:leave).select('user_leaves.id, leaves.name').where(
      'user_id = ? AND remaining_count > ?', current_user.id, 0
    )
    @applied_leave = AppliedLeave.new
    respond_to do |format|
      format.html
    end
  end

  # POST   /applied_leaves
  def create
    @applied_leave = AppliedLeave.new(applied_leave_params)
    is_saved = @applied_leave.save if @applied_leave.leave_count_available?
    respond_to do |format|
      format.html do
        return redirect_to action: 'index', notice: 'Leave applied successfully' if is_saved

        flash.now[:error] = @applied_leave.errors.full_messages
        render :new
      end
    end
  end

  # GET    /applied_leaves/:id/edit
  def edit; end

  # PATCH/PUT  /applied_leaves/:id
  def update; end

  # DELETE /applied_leaves/:id
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

  # GET    /applied_leaves/show_applied_leaves
  def show_applied_leaves
    @applied_leaves = AppliedLeave.all
    respond_to do |format|
      format.html
    end
  end

  # PATCH  /applied_leaves/:id/approve_leave
  def approve_leave
    is_saved = @applied_leave.approve_applied_leave
    binding.pry
    respond_to do |format|
      format.html do
        return redirect_to action: 'show_applied_leaves', notice: 'Leave approved successfully' if is_saved

        flash.now[:error] = @applied_leave.errors.full_messages
        render :show_applied_leaves
      end
    end
  end

  # PATCH  /applied_leaves/:id/reject_leave
  def reject_leave
    return unless @applied_leave.pending?

    @applied_leave.request_rejected
    is_saved = @applied_leave.save
    respond_to do |format|
      format.html do
        return redirect_to action: 'show_applied_leaves', notice: 'Leave rejected successfully' if is_saved

        flash.now[:error] = @applied_leave.errors.full_messages
        render :display_pending_leaves
      end
    end
  end

  # PATCH  /applied_leaves/approve_multiple_leaves
  def approve_multiple_leaves
    binding.pry
    respond_to do |format|
      format.js
    end
  end

  # PATCH  /applied_leaves/reject_multiple_leaves
  def reject_multiple_leaves
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

  def applied_leave_params
    params.require(:applied_leave).permit(:user_leave_id, :applied_at, :applied_till, :leave_duration_id)
  end

  def multiple_leave_params
    params.permit(:applied_leave_ids)
  end
end
