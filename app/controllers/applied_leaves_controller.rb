class AppliedLeavesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[index new create edit update destroy]
  before_action :set_applied_leave, only: %i[approve_leave reject_leave]
  before_action :set_user_applied_leave, only: %i[show edit update]
  before_action :get_available_leaves, only: %i[new edit]
  before_action :get_applied_leaves, only: :show_applied_leaves

  # GET /members/:member_id/applied_leaves
  def index
    # UserMailer.leave_application_email(['chabdulbasit1122@gmail.com', 'bcsf17m526@pucit.edu.pk']).deliver_now
    emails = current_company.users.where(role_id: User::ROLES[:department_head]).where(department_id: current_user.department_id).or(current_company.users.where(role_id: User::ROLES[:hr]))
      binding.pry
    @applied_leaves = @user.applied_leaves.includes(:leave)
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

  # POST /members/:member_id/applied_leaves
  def create
    @applied_leave = @user.applied_leaves.build(applied_leave_params)
    @applied_leave.leave_id = @applied_leave.user_leave.leave&.id
    is_saved = @applied_leave.save if @applied_leave.validate_leave_year && @applied_leave.leave_available?
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
  def edit; end

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

  # GET /applied_leaves/show_applied_leaves
  def show_applied_leaves
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
          flash[:error] = @applied_leave.errors.full_messages
        end
        redirect_to show_applied_leaves_path
      end
    end
  end

  # PATCH /applied_leaves/approve_multiple_leaves
  def approve_multiple_leaves
    count_approved = AppliedLeave.approve_multiple_applied_leaves(params[:applied_leave_ids])
    get_filtered_records
    respond_to do |format|
      format.js do
        flash[:notice] = t('applied_leave.messages.mass_approve', total: total_request_count, actual: count_approved)
      end
    end
  end

  # PATCH /applied_leaves/reject_multiple_leaves
  def reject_multiple_leaves
    count_rejected = AppliedLeave.reject_multiple_applied_leaves(params[:applied_leave_ids])
    get_filtered_records
    respond_to do |format|
      format.js do
        flash[:notice] = t('applied_leave.messages.mass_reject', total: total_request_count, actual: count_rejected)
        render 'approve_multiple_leaves'
      end
    end
  end

  # GET /applied_leaves/filter_applied_leaves
  def filter_applied_leaves
    get_filtered_records
    respond_to do |format|
      format.js { render 'approve_multiple_leaves' }
    end
  end

  private

  def total_request_count
    return params[:applied_leave_ids].size if params[:applied_leave_ids]

    0
  end

  def get_available_leaves
    @available_user_leaves = @user.user_leaves.joins(:leave).where('user_leaves.remaining_count > ?',
                                                                   0).select('user_leaves.id, leaves.name')
  end

  def get_applied_leaves
    @applied_leaves = @current_company.applied_leaves.includes(user_leave: %i[user leave])
  end

  def get_filtered_records
    @applied_leaves = AppliedLeave.get_filtered_records(params[:filter_type].to_s.downcase)
    @applied_leaves.includes(user_leave: %i[user leave])
  end

  def applied_leave_params
    params.require(:applied_leave).permit(:user_leave_id, :applied_from, :applied_till, :leave_duration_type)
  end

  def set_user
    @user = User.find(params[:member_id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t('common.user_not_found')
    redirect_to members_path
  end

  def set_user_applied_leave
    @applied_leave = @user.applied_leaves.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t('applied_leave.messages.error.not_found')
    redirect_to member_applied_leaves_path(@user)
  end

  def set_applied_leave
    @applied_leave = AppliedLeave.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t('applied_leave.messages.error.not_found')
    redirect_to member_applied_leaves_path(@user)
  end
end
