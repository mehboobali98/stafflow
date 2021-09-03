class UserBenefitsController < ApplicationController
  def index
    @user_benefit = UserBenefit.joins(:benefit).joins(:user)
  end

  def new
    @user_benefit = UserBenefit.joins(:benefit).new
  end

  def create; end

  def show
    @user_benefit = UserBenefit.find(params[:id])
  end

  def destroy; end

  def update
    @user_benefit = UserBenefit.find(params[:id])
    if @user_benefit.update(user_benefit_arguments)
      flash[:notice] = 'User benefit Updated Successfully'
      redirect_to action: 'index'
    else
      flash[:alert] = @user_benefit.errors.full_messages.first
      redirect_back(fallback_location: root_path)
    end
  end

  def user_benefit_arguments
    params.require(:user_benefit).permit(:amount, :status)
  end
end
