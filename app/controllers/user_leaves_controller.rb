class UserLeavesController < ApplicationController
  before_action :authenticate_user!
  layout 'leave_layout'

  # GET    /members/:member_id/user_leaves/show
  def show
    @user = find_user_by_id
    @user_leaves = @user.user_leaves
  end

  # GET    /user_leaves/new
  def new
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

  private

  def user_leave_params
    params.require(:user_leave).permit(leave: {})
  end

  def user_params
    params.require(:member_id)
  end

  def find_user_by_id
    @user = User.find_by(id: user_params)
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = e.message
    redirect_to leaves_path
  end
end
