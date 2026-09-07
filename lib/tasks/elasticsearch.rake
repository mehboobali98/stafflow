# frozen_string_literal: true

namespace :elasticsearch do
  desc 'Create the search indices from their mappings and fill them from every tenant'
  task reindex: :environment do
    TenantSearch.reindex_all!

    puts "Indexed #{TenantSearch::MODELS.map(&:index_name).join(', ')}"
  end
end
