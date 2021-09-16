class UserLeavesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_user_leave, only: %i[show edit update destroy]

  # GET    /members/:member_id/user_leaves/:id
  def show
    respond_to do |format|
      format.html
    end
  end

  # GET    /members/:member_id/user_leaves
  def index
    @user_leaves = @user.user_leaves
    respond_to do |format|
      format.html
    end
  end

  # GET    /members/:member_id/user_leaves/new
  def new
    @leave = Leave.all
    respond_to do |format|
      format.html
    end
  end

  # POST   /members/:member_id/user_leaves
  def create
    is_saved = UserLeave.add_user_leave(@user.id, user_leave_params)
    respond_to do |format|
      format.html do
        if is_saved
          redirect_to member_user_leaves_path(@user),
                      notice: t('user_leave.messages.success.create_success')
        end
        flash.now[:error] = t('user_leave.messages.failure.create_failure')
        render :new
      end
    end
  end

  # GET    /members/:member_id/applied_leaves/:id/edit
  def edit
    respond_to do |format|
      format.js
    end
  end

  # PATCH/PUT  /members/:member_id/applied_leaves/:id
  def update
    is_updated = @user_leave.update(user_leave_update_params)
    respond_to do |format|
      format.js do
        return flash.now[:error] = @user_leave.errors.full_messages unless is_updated

        flash.now[:notice] = t('user_leave.messages.success.create_success')
        # render js: "window.location = '#{member_user_leaves_path(@user)}'"
        @user_leaves = @user.user_leaves
      end
    end
  end

  # Destroy /members/:member_id/applied_leaves/:id
  def destroy
    @user_leave.destroy
    is_destroyed = @user_leave.destroyed?
    respond_to do |format|
      format.html do
        flash[:error] = @user_leave.errors.full_messages unless is_destroyed
        flash[:notice] = t('user_leave.messages.success.delete')
        redirect_to member_user_leaves_path(@user)
      end
    end
  end

  private

  def user_leave_update_params
    params.require(:user_leave).permit(:member_id, :total_count, :remaining_count)
  end

  def user_leave_params
    params.require(:user_leave).permit(leave: {})
  end

  def user_params
    params.require(:member_id)
  end

  def set_user_leave
    @user_leave = @user.user_leaves.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = e.message
    redirect_to member_user_leaves_path(@user)
  end

  def set_user
    @user = User.find(user_params)
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = e.message
    redirect_to members_path
  end
end
