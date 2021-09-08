class UserLeavesController < ApplicationController
  def new
    @leave = Leave.all
    respond_to do |format|
      format.html
    end
  end

  def create
    binding.pry
    @user = current_user
  end

  def edit; end

  def update; end

  def apply_for_leave
    @user_leaves = get_current_user.user_leaves
  end

  private

  def user_leave_params
    params.require(:leave).permit(leave: {})
    #params.require(:leave).permit
  end

  def get_current_user
    @get_current_user ||= current_user
  end
end
