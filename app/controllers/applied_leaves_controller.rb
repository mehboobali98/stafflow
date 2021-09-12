class AppliedLeavesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_applied_leave, only: %i[show edit update destroy]
  before_action :get_filtered_records, only: %i[approve_multiple_leaves reject_multiple_leaves filter_applied_leaves]
  # GET    /applied_leaves
  def index
    @applied_leaves = AppliedLeave.joins(:user_leave).where(user_leaves: { user_id: current_user.id })
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
    @applied_leave = AppliedLeave.new
    is_saved = @applied_leave.save if @applied_leave.validate_leave_date_year && @applied_leave.leave_count_available?
    respond_to do |format|
      format.html do
        return redirect_to action: 'index', notice: t('applied_leave.messages.leave_applied_success') if is_saved

        flash.now[:error] = @applied_leave.errors.full_messages
        render :new
      end
    end
  end

  # GET    /applied_leaves/:id/edit
  def edit; end

  # PATCH/PUT  /applied_leaves/:id
  def update
    is_updated = @applied_leave.update(applied_leave_params)
    respond_to do |format|
      format.html do
        return redirect_to leaves_path, notice: t('applied_leave.messages.leave_update_success') if is_updated

        flash.now[:error] = @leave.errors.full_messages
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
    @applied_leaves = AppliedLeave.all
    respond_to do |format|
      format.html
    end
  end

  # PATCH  /applied_leaves/:id/approve_leave
  def approve_leave
    is_saved = @applied_leave.approve_applied_leave
    respond_to do |format|
      format.html do
        if is_saved
          return redirect_to action: 'show_applied_leaves',
                             notice: t('applied_leave.messages.leave_approve_success')
        end

        flash.now[:error] = @applied_leave.errors.full_messages
        render :show_applied_leaves
      end
    end
  end

  # PATCH  /applied_leaves/:id/reject_leave
  def reject_leave
    is_saved = @applied_leave.reject_applied_leave
    respond_to do |format|
      format.html do
        if is_saved
          return redirect_to action: 'show_applied_leaves',
                             notice: t('applied_leave.messages.leave_reject_success')
        end

        flash.now[:error] = @applied_leave.errors.full_messages
        render :display_pending_leaves
      end
    end
  end

  # PATCH  /applied_leaves/approve_multiple_leaves
  def approve_multiple_leaves
    AppliedLeave.approve_multiple_applied_leaves(multiple_leave_params)
    respond_to do |format|
      format.js
    end
  end

  # PATCH  /applied_leaves/reject_multiple_leaves
  def reject_multiple_leaves
    AppliedLeave.reject_multiple_applied_leaves(multiple_leave_params)
    respond_to do |format|
      format.js
    end
  end

  # GET    /applied_leaves/filter_applied_leaves
  def filter_applied_leaves
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
    params.permit(:filter_type)
  end
end
