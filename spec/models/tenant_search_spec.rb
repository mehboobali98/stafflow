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

  # Elasticsearch is not rolled back with the test transaction. Reindexing with
  # no tenant set swaps in an empty index, because the default scope matches
  # nothing - the clean slate each example needs.
  before do
    globex_records = [
      employee_named(globex, 'Zephyrine'),
      employee_named(globex, 'Marguerite'),
      as_tenant(globex) { create(:department, company: globex, name: 'Ornithology') }
    ]

    [User, Department, Designation].each(&:reindex)
    as_tenant(acme)   { acme_person.reindex }
    as_tenant(globex) { globex_records.each(&:reindex) }
    [User, Department, Designation].each { |model| model.search_index.refresh }
  end

  describe '.call' do
    it 'returns the current tenant own records' do
      found = as_tenant(acme) { described_class.call('Zephyrine').to_a }

      expect(found).to contain_exactly(acme_person)
    end

    it 'counts only the current tenant hits when both tenants match' do
      count = as_tenant(acme) { described_class.call('Zephyrine').total_count }

      expect(count).to eq(1)
    end

    it 'reports no hits for a name only another tenant has' do
      results = as_tenant(acme) { described_class.call('Marguerite') }

      expect(results.total_count).to eq(0)
      expect(results.to_a).to be_empty
    end

    it 'filters every searched model, not only users' do
      results = as_tenant(acme) { described_class.call('Ornithology') }

      expect(results.total_count).to eq(0)
      expect(results.to_a).to be_empty
    end

    it 'finds nothing when no tenant is set' do
      results = described_class.call('Zephyrine')

      expect(results.total_count).to eq(0)
      expect(results.to_a).to be_empty
    end
  end
end
