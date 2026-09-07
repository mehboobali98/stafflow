# frozen_string_literal: true

module TenantSearch
  MODELS = [User, Department, Designation].freeze

  # The default scope cannot reach this: it only narrows the records loaded for
  # the ids Elasticsearch returns, leaving the hit count describing every
  # tenant. The filter below is what makes the count the tenant's own.
  #
  # An unset tenant filters on `company_id: 0`, which no record has, so it finds
  # nothing rather than everything - the same way the default scope fails
  # closed. `nil` could not be sent as a term, so the fallback is explicit.
  #
  # @param query [String] the raw search box input
  # @return [Elasticsearch::Model::Response::Records] Active Record objects,
  #   carrying the Elasticsearch hit count as `total`
  def self.call(query)
    Elasticsearch::Model.search(body(query), MODELS).records
  end

  # Builds every index from its mapping and fills it from every tenant.
  #
  # Elasticsearch creates an index from a dynamic mapping the first time a
  # document is written to a name that does not exist, and the indexing callback
  # on a first save is exactly that. An index made that way carries no prefix
  # analyzer, so partial-word search stops matching while every request still
  # answers 200. Seeding writes records, so this runs after it rather than
  # before: it replaces whatever the callbacks left behind.
  #
  # @return [void]
  def self.reindex_all!
    MODELS.each { |model| model.__elasticsearch__.create_index!(force: true) }

    # The models are tenant-scoped, so an import with no tenant set reads
    # nothing. Company opts out of that scope, so this loop sees them all.
    Company.find_each do |company|
      Company.current_company_id = company.id
      MODELS.each { |model| model.__elasticsearch__.import }
    end
  ensure
    Company.current_company_id = nil
    MODELS.each { |model| model.__elasticsearch__.refresh_index! }
  end

  # Searches both column names in one request, because a document holds only the
  # one its own model indexes; a field absent from a document simply does not
  # match rather than erroring.
  #
  # @param query [String] the raw search box input
  # @return [Hash] the Elasticsearch request body
  def self.body(query)
    {
      query: {
        bool: {
          must: [{ multi_match: { query: query.to_s, fields: %w[first_name name] } }],
          filter: [{ term: { company_id: Company.current_company_id.to_i } }]
        }
      }
    }
  end
  private_class_method :body
end
