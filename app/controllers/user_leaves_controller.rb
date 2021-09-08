class UserLeavesController < ApplicationController
  def new
    @leave = Leave.all
    respond_to do |format|
      format.html
    end
  end

  def create
    @user = current_user
    user_leave_params.values[0].each_value do |value|
      @user.user_leaves.build(value.merge(remaining_count: value[:total_count]))
    end
    @user.save
    redirect_to controller: :home, action: :index
  end

  def edit; end

  def update; end

  private

  def user_leave_params
    params.require(:user_leave).permit(leave: {})
  end
end
