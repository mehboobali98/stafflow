class SearchController < ApplicationController
  def search_data
    @results = Searchkick.search params[:search_query], models: [User, Department, Designation]
    respond_to do |format|
      format.html
    end
  end
end
