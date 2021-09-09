class HomeController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: %i[index]
  def index
    User.unscoped do
    @total_companies= Company.joins(:users).where(users:{email:params[:user][:email]}).load
    end
  end
  def home; end

  private
 # def permitted_home_params
 #    params.require(:user).permit(:email)
 #  end


end
