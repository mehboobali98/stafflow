# frozen_string_literal: true

require 'rails_helper'

# The count and the records come from different places: Elasticsearch answers
# the query, Active Record loads the ids it returns. Only the second is scoped
# by default.
RSpec.describe TenantSearch do
  let!(:acme)   { create(:company, name: 'Acme',   subdomain: 'acme') }
  let!(:globex) { create(:company, name: 'Globex', subdomain: 'globex') }

  let!(:acme_person) { employee_named(acme, 'Zephyrine') }

  def employee_named(company, first_name)
    department = as_tenant(company) { create(:department, company: company) }

    as_tenant(company) do
      create(:user, :employee, company: company, department: department, first_name: first_name)
    end
  end

  # Elasticsearch is not rolled back with the test transaction, so each example
  # rebuilds the indices. `create_index!` rather than the concern's `reindex` is
  # deliberate: both tenants' records have to land in one index for the filter
  # to have anything to exclude, and `reindex` imports only the current tenant.
  before do
    globex_records = [
      employee_named(globex, 'Zephyrine'),
      employee_named(globex, 'Marguerite'),
      as_tenant(globex) { create(:department, company: globex, name: 'Ornithology') }
    ]

    TenantSearch::MODELS.each { |model| model.__elasticsearch__.create_index!(force: true) }
    as_tenant(acme)   { acme_person.__elasticsearch__.index_document }
    as_tenant(globex) { globex_records.each { |record| record.__elasticsearch__.index_document } }
    TenantSearch::MODELS.each { |model| model.__elasticsearch__.refresh_index! }
  end

  describe '.call' do
    it 'returns the current tenant own records' do
      found = as_tenant(acme) { described_class.call('Zephyrine').to_a }

      expect(found).to contain_exactly(acme_person)
    end

    it 'counts only the current tenant hits when both tenants match' do
      count = as_tenant(acme) { described_class.call('Zephyrine').total }

      expect(count).to eq(1)
    end

    it 'reports no hits for a name only another tenant has' do
      results = as_tenant(acme) { described_class.call('Marguerite') }

      expect(results.total).to eq(0)
      expect(results.to_a).to be_empty
    end

    it 'filters every searched model, not only users' do
      results = as_tenant(acme) { described_class.call('Ornithology') }

      expect(results.total).to eq(0)
      expect(results.to_a).to be_empty
    end

    it 'finds nothing when no tenant is set' do
      results = described_class.call('Zephyrine')

      expect(results.total).to eq(0)
      expect(results.to_a).to be_empty
    end

    # The prefix analyzer exists only if the index was built from the mapping.
    # An index Elasticsearch creates for itself - which is what a callback
    # writing to a missing index produces - maps the column as plain text, and
    # then this is the only thing that changes: whole words still match, so
    # every other example here and every request still passes while partial
    # search has quietly stopped working.
    it 'matches a partial word, which only the mapped analyzer allows' do
      found = as_tenant(acme) { described_class.call('Zephyr').to_a }

      expect(found).to contain_exactly(acme_person)
    end
  end

  # searchkick indexed `serializable_hash`, so a user document carried base
  # salary, date of birth, gender and three foreign keys - none of which the
  # search reads, since it matches one column and loads the record from MySQL.
  # `as_indexed_json` is what replaced that, and this asserts the result rather
  # than the intent by reading the document back out of Elasticsearch.
  describe 'the indexed document' do
    it 'holds the searched column and the tenant id, and nothing else' do
      source = as_tenant(acme) do
        User.__elasticsearch__.client.get(index: User.index_name, id: acme_person.id)['_source']
      end

      expect(source.keys).to contain_exactly('first_name', 'company_id')
    end
  end
end
