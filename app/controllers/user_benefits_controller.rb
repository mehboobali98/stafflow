class UserBenefitsController < ApplicationController
  def index
    @user_benefit = UserBenefit.joins(:benefit)
  end

  def new
    @user_benefit = UserBenefit.joins(:benefit).new
  end

  def create; end

  def show
    @user_benefit = UserBenefit.find(params[:id])
  end
end
