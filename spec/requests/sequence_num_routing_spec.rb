# frozen_string_literal: true

require 'rails_helper'

# sequence_num is the URL identifier, not the primary key: `to_param` puts it
# in generated paths and the controllers load records back with
# `find_by: :sequence_num`. Those two halves only work as a pair, so this goes
# through the router to check them together rather than in isolation.
RSpec.describe 'records addressed by sequence number', type: :request do
  let!(:company) { create(:company, subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }

  let!(:hr) do
    as_tenant(company) do
      create(:user, :hr, company: company, department: department,
                         email: 'hr@example.com', password: 'password123')
    end
  end

  def host
    { 'HTTP_HOST' => 'acme.localhost' }
  end

  before do
    post '/users/sign_in',
         params: { user: { email: 'hr@example.com', password: 'password123' } },
         headers: host
  end

  it 'builds the edit path from the sequence number rather than the id' do
    benefit = as_tenant(company) { create(:benefit, company: company) }

    expect(edit_benefit_path(benefit)).to eq("/benefits/#{benefit.sequence_num}/edit")
  end

  it 'loads the record back from that path' do
    first  = as_tenant(company) { create(:benefit, company: company) }
    second = as_tenant(company) { create(:benefit, company: company) }

    get edit_benefit_path(second), headers: host

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(second.name)
    expect(response.body).not_to include(first.name)
  end

  # Two companies both number their first benefit 1, so the path alone does not
  # identify a row - the tenant scope is what disambiguates it.
  it 'resolves the same number to each company own record' do
    ours = as_tenant(company) { create(:benefit, company: company) }

    other = create(:company, subdomain: 'globex')
    theirs = as_tenant(other) { create(:benefit, company: other) }

    expect(ours.sequence_num).to eq(theirs.sequence_num)

    get edit_benefit_path(ours), headers: host

    expect(response.body).to include(ours.name)
    expect(response.body).not_to include(theirs.name)
  end

  it 'answers 404 for a number that belongs to no record here' do
    get edit_benefit_path(9999), headers: host

    expect(response).to have_http_status(:not_found)
  end
end
