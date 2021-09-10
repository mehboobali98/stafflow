class HomeController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: %i[display_companies]

  def display_companies
    User.unscoped do
      @total_companies = Company.joins(:users).where(users: { email: params[:user][:email] }).load
    end
  end
end
