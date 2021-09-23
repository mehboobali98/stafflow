class SearchController < ApplicationController
  def get_search_data
        binding.pry
    result = Searchkick.search "nadia", models: [User, Department, Designation]
  end
end
