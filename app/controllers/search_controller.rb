class SearchController < ApplicationController
  before_action :authenticate_user!

  def search_data
    @results = TenantSearch.call(params[:search_query])
    respond_to do |format|
      format.html
    end
  end
end
