# frozen_string_literal: true

require 'rails_helper'

# Search is the one read path that does not go through Active Record first: it
# asks Elasticsearch for ids and then loads them. The index is not partitioned
# by company, so the only thing keeping one tenant's records out of another's
# results is the default scope applied when those ids are loaded. That is worth
# holding still across a searchkick major version.
RSpec.describe 'search', type: :request do
  let!(:acme)   { create(:company, name: 'Acme',   subdomain: 'acme') }
  let!(:globex) { create(:company, name: 'Globex', subdomain: 'globex') }

  def employee_named(company, first_name, email)
    department = as_tenant(company) { create(:department, company: company) }

    as_tenant(company) do
      create(:user, :employee, company: company, department: department,
                               first_name: first_name, email: email)
    end
  end

  before do
    employee_named(acme,   'Zephyrine', 'acme-employee@example.com')
    employee_named(globex, 'Zephyrine', 'globex-employee@example.com')

    # Elasticsearch is not rolled back with the test transaction, so the index
    # is swapped empty first. With no tenant set the default scope matches
    # nothing, which is exactly the clean slate wanted here.
    User.reindex
    as_tenant(acme)   { User.first.reindex }
    as_tenant(globex) { User.first.reindex }
    User.search_index.refresh
  end

  it 'finds the current tenant own people' do
    found = as_tenant(acme) { Searchkick.search('Zephyrine', models: [User]).to_a }

    expect(found.map(&:email)).to contain_exactly('acme-employee@example.com')
  end

  it 'does not return another tenant people, though the index holds them' do
    found = as_tenant(globex) { Searchkick.search('Zephyrine', models: [User]).to_a }

    expect(found.map(&:email)).to contain_exactly('globex-employee@example.com')
  end
end
