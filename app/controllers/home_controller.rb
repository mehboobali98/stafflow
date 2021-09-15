class HomeController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: %i[display_companies]
  layout 'landing'

  # GET /display_companies
  def display_companies
    User.unscoped do
      @companies = Company.joins(:users).where(users: { email: home_params[:email] }).load # If Load not used, then in templte, default scope applied and query changed.
    end
    respond_to do |format|
      format.html
    end
  end

  private

  def home_params
    params.require(:user).permit(:email)
  end
end
