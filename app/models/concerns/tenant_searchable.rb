# frozen_string_literal: true

# Elasticsearch indexing for the three models the navbar search spans.
#
# Three things it owns beyond wiring `Elasticsearch::Model` in.
#
# **The document holds the searched column and `company_id` and nothing else.**
# searchkick, which this replaces, indexed `serializable_hash` unless a model
# overrode it and none did, so a user document carried base salary, date of
# birth, gender, and the role, department and designation ids - none of which
# the search reads. It matches on one column and then loads the records from
# MySQL by id, which is the same argument that put `.select(:id, :email)` on the
# employee lookup.
#
# **The index is named per environment.** One Elasticsearch serves development
# and test here, and the default name is the model's collection name, so both
# would write to `users`. searchkick appended the environment; so does this.
#
# **The analyzer only exists if the index was created deliberately.**
# Elasticsearch builds an index from a dynamic mapping the first time a document
# is written to a name that does not exist, and a callback write is exactly that
# - so an index that was never created explicitly has no prefix analyzer, and
# partial-word search quietly stops matching while everything still answers 200.
module TenantSearchable
  extend ActiveSupport::Concern

  # Prefix matching: "Eng" finds "Engineering". The edge n-gram filter runs at
  # index time only. Applying it to the query as well would let any shared
  # prefix of any length match, so "E" would find every word starting with "E"
  # by way of the query being n-grammed too - the search analyzer is the plain
  # lowercased tokenizer instead.
  ANALYSIS = {
    analyzer: {
      word_start: {
        type: 'custom',
        tokenizer: 'standard',
        filter: %w[lowercase word_start_edges]
      },
      word_start_search: {
        type: 'custom',
        tokenizer: 'standard',
        filter: %w[lowercase]
      }
    },
    filter: {
      word_start_edges: { type: 'edge_ngram', min_gram: 1, max_gram: 30 }
    }
  }.freeze

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    index_name "#{model_name.collection}_#{Rails.env}"
  end

  class_methods do
    # @param attribute [Symbol] the one column this model is searched on
    # @return [void]
    def searchable_on(attribute)
      @searchable_attribute = attribute

      settings index: { analysis: ANALYSIS } do
        mappings dynamic: false do
          indexes attribute, type: :text, analyzer: :word_start, search_analyzer: :word_start_search
          indexes :company_id, type: :integer
        end
      end

      define_method(:as_indexed_json) do |_options = nil|
        { attribute => public_send(attribute), 'company_id' => company_id }
      end
    end

    # @return [Symbol] the column this model is searched on
    def searchable_attribute
      @searchable_attribute
    end

    # Drops and rebuilds the index from the records the current tenant can see,
    # mapping and analyzer included. This is the only path that creates an index
    # correctly - see the note on dynamic mapping above.
    #
    # @return [void]
    def reindex
      __elasticsearch__.create_index!(force: true)
      __elasticsearch__.import
      __elasticsearch__.refresh_index!
    end
  end
end
