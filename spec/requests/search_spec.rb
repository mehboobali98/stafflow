# frozen_string_literal: true

require 'rails_helper'

# TenantSearch filters the Elasticsearch query itself, so the default scope is
# no longer what keeps one tenant's people out of another's results. The two
# examples that exercise it stay because it is the guard behind that filter,
# and that is worth holding still across a searchkick major version.
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
    acme_person = employee_named(acme, 'Zephyrine', 'acme-employee@example.com')
    globex_people = [
      employee_named(globex, 'Zephyrine',  'globex-employee@example.com'),
      employee_named(globex, 'Marguerite', 'globex-only@example.com')
    ]

    # Elasticsearch is not rolled back with the test transaction. Reindexing with
    # no tenant set swaps in an empty index, because the default scope matches
    # nothing - the clean slate each example needs.
    [User, Department, Designation].each(&:reindex)
    as_tenant(acme)   { acme_person.reindex }
    as_tenant(globex) { globex_people.each(&:reindex) }
    [User, Department, Designation].each { |model| model.search_index.refresh }
  end

  describe 'the default scope behind the query filter' do
    it 'finds the current tenant own people' do
      found = as_tenant(acme) { Searchkick.search('Zephyrine', models: [User]).to_a }

      expect(found.map(&:email)).to contain_exactly('acme-employee@example.com')
    end

    it 'does not return another tenant people, though the index holds them' do
      found = as_tenant(globex) { Searchkick.search('Zephyrine', models: [User]).to_a }

      expect(found.map(&:email)).to contain_exactly('globex-employee@example.com')
    end
  end

  describe 'GET /search/search_data' do
    before do
      host! 'acme.localhost'
      post '/users/sign_in',
           params: { user: { email: 'acme-employee@example.com', password: 'password123' } }
    end

    def search_for(query)
      get '/search/search_data', params: { search_query: query }
      response.body
    end

    it 'renders the current tenant matches' do
      body = search_for('Zephyrine')

      expect(body).to include('acme-employee@example.com')
      expect(body).not_to include('globex-employee@example.com')
    end

    it 'shows the empty state for a name only another tenant has' do
      expect(search_for('Marguerite')).to include('No Data Found')
    end
  end
end
