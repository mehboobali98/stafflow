class SearchController < ApplicationController
  def get_search_data
    result = Searchkick.search "nadia", models: [User, Department, Designation]
    binding.pry
  end
end
