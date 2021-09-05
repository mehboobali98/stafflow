class AppliedLeavesController < ApplicationController
  def new
    @user_leaves = UserLeave.joins(:leave).select('user_leaves.id, leaves.name').where(user_id: get_current_user.id)
    @applied_leave = AppliedLeave.new
  end

  def create
    binding.pry
    @user = current_user
  end

  def edit; end

  def update; end

  private

  def user_leave_params; end

  def get_current_user
    @get_current_user ||= current_user
  end
end
