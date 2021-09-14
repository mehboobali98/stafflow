class UserLeavesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  layout 'leave_layout'

  # GET    /members/:member_id/user_leaves/:id
  def show
    @user_leaves = @user.user_leaves
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
    @user = set_user
    @leave = Leave.all
    respond_to do |format|
      format.html
    end
  end

  # POST   /user_leaves/create
  def create
    is_saved = UserLeave.add_user_leave(current_user.id, user_leave_params)
    respond_to do |format|
      format.html do
        if is_saved
          return redirect_to controller: :home, action: :index,
                             notice: t('user_leave.messages.success.create_success')
        end
        flash.now[:error] = t('user_leave.messages.failure.create_failure')
        render :new
      end
    end
  end

  # GET    /members/:member_id/applied_leaves/:id/edit
  def edit
    @user = set_user
    @user_leave = set_user_leave
    respond_to do |format|
      format.js
    end
  end

  # PATCH/PUT  /members/:member_id/applied_leaves/:id
  def update
    binding.pry
    @user_leave = set_user_leave
    is_updated = @user_leave.update(user_leave_update_params)
    respond_to do |format|
      format.html do
        return redirect_to leaves_path, notice: t('leave.messages.success.edit_success') if is_updated

        flash.now[:error] = @user_leave.errors.full_messages
        render :edit
      end
    end
  end

  # Destroy /members/:member_id/applied_leaves/:id
  def destroy; end

  private

  def user_leave_update_params
    binding.pry
    params.require(:user_leave).permit(:member_id, :id, :remaining_count)
  end

  def user_leave_params
    params.require(:user_leave).permit(leave: {})
  end

  def user_params
    params.require(:member_id)
  end

  def set_user_leave
    @user_leave = UserLeave.find_by(id: params[:id])
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = e.message
    redirect_to leaves_path
  end

  def set_user
    @user = User.find_by(id: user_params)
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = e.message
    redirect_to leaves_path
  end
end
