class HomeController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: %i[display_companies]

  # POST /display_companies
  def display_companies
    User.unscoped do
      @companies = Company.joins(:users).where(users: { email: params[:user][:email] }).load
    end
    respond_to do |format|
      format.html
    end
  end
end
