class HomeController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: %i[display_companies index]
  layout 'landing'
  layout 'signup', only: :index

  # GET /display_companies
  def display_companies
    User.unscoped do
      @companies = Company.joins(:users).where(users: { email: home_params[:email] }).load # If Load not used, then in template, default scope applied and query changed.
    end
    respond_to do |format|
      if @companies.length == 1
        # Deliberately leaves the apex host: the tenant lives on its own
        # subdomain, and this is the hop that carries sign-in to it.
        return redirect_to new_user_session_url(subdomain: @companies.first.subdomain,
                                                email: home_params[:email]),
                           allow_other_host: true
      else
        format.html { render layout: 'landing' }
      end
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
