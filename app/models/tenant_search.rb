# frozen_string_literal: true

module TenantSearch
  # The default scope cannot reach this: it only narrows the records loaded for
  # the ids Elasticsearch returns, leaving the hit count describing every
  # tenant. A nil tenant matches documents with no company_id, of which there
  # are none, so an unset tenant finds nothing rather than everything.
  def self.call(query)
    Searchkick.search(query,
                      models: [User, Department, Designation],
                      where: { company_id: Company.current_company_id })
  end
end
