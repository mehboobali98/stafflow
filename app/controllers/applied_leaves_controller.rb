class AppliedLeavesController < ApplicationController
  before_action :authenticate_user!

  def index
    @applied_leaves = AppliedLeave.joins(:user_leave).where(user_leaves: { user_id: get_current_user.id })
    binding.pry
  end

  def show; end

  def new
    @user_leaves = UserLeave.joins(:leave).select('user_leaves.id, leaves.name').where(
      'user_id = ? AND remaining_count > ?', get_current_user.id, 0
    )
    @applied_leave = AppliedLeave.new
  end

  def create
    @applied_leave = AppliedLeave.new(applied_leave_params)
    if @applied_leave.save
      redirect_to action: 'index', notice: 'Leave applied successfully'
    else
      render :new
    end
  end

  def edit; end

  def update; end

  private

  def applied_leave_params
    params.require(:applied_leave).permit(:user_leave_id, :applied_at, :applied_till)
  end

  def get_current_user
    @get_current_user ||= current_user
  end
end
