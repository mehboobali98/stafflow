class UserLeavesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_user_leave, only: %i[show edit update destroy]

  # GET /members/:member_id/user_leaves/:id
  def show
    respond_to do |format|
      format.html
    end
  end

  # GET /members/:member_id/user_leaves
  def index
    @user_leaves = @user.user_leaves.includes(:leave)
    respond_to do |format|
      format.html
    end
  end

  # GET /members/:member_id/user_leaves/new
  def new
  binding.pry
    @leaves = @current_company.leaves.where.not(id: @user.leaves.ids)
    respond_to do |format|
      format.html
    end
  end

  # POST /members/:member_id/user_leaves/mass_create
  def mass_create
    is_saved = UserLeave.add_user_leaves(@user, user_leave_params)
    respond_to do |format|
      format.html do
        if is_saved
          redirect_to member_user_leaves_path(@user),
                      notice: t('user_leave.messages.success.create')
        else
          flash[:error] = t('user_leave.messages.failure.create')
          redirect_to new_member_user_leave_path(@user)
        end
      end
    end
  end

  # GET /members/:member_id/applied_leaves/:id/edit
  def edit
    respond_to do |format|
      format.js
    end
  end

  # PATCH/PUT /members/:member_id/applied_leaves/:id
  def update
    is_updated = @user_leave.update(user_leave_update_params)
    respond_to do |format|
      format.js do
        if is_updated
          flash[:notice] = t('user_leave.messages.success.update')
          render js: "window.location = '#{member_user_leaves_path(@user)}'"
        else
          flash.now[:error] = @user_leave.errors.full_messages
        end
      end
    end
  end

  # Destroy /members/:member_id/applied_leaves/:id
  def destroy
    @user_leave.destroy
    respond_to do |format|
      format.html do
        if @user_leave.destroyed?
          flash[:notice] = t('user_leave.messages.success.delete')
        else
          flash[:error] = @user_leave.errors.full_messages
        end
        redirect_to member_user_leaves_path(@user)
      end
    end
  end

  private

  def user_leave_update_params
    params.require(:user_leave).permit(:total_count, :remaining_count)
  end

  def user_leave_params
    params.permit(leave: {})
  end

  def set_user_leave
    @user_leave = @user.user_leaves.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t('user_leave.messages.failure.not_found')
    redirect_to member_user_leaves_path(@user)
  end

  def set_user
    @user = User.find(params[:member_id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t('common.user_not_found')
    redirect_to members_path
  end
end
