class HomeController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: %i[display_companies index]
  layout 'landing', only: :display_companies
  layout 'signup', only: :index

  # GET /display_companies
  def display_companies
    User.unscoped do
      @companies = Company.joins(:users).where(users: { email: home_params[:email] }).load # If Load not used, then in template, default scope applied and query changed.
    end
    respond_to do |format|
      format.html
    end
  end

  # GET /home
  def index
    respond_to do |format|
      format.html
    end
  end

  private

  def home_params
    params.require(:user).permit(:email)
  end
end
