class UserLeavesController < ApplicationController
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
end
