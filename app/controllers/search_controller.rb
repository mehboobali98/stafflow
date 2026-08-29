class SearchController < ApplicationController
  before_action :authenticate_user!

  def search_data
    @results = Searchkick.search params[:search_query], models: [User, Department, Designation]
    respond_to do |format|
      format.html
    end
  end
end
