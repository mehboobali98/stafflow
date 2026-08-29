# frozen_string_literal: true

require 'rails_helper'

# Every other controller answers an anonymous request with 403 through CanCan.
# Search had neither an authentication filter nor a resource to authorize, so
# it ran a real Elasticsearch query across every tenant's records first.
RSpec.describe 'search authorization', type: :request do
  before { create(:company, subdomain: 'acme') }

  it 'sends an anonymous visitor to sign in rather than running a search' do
    get '/search/search_data',
        params: { search_query: 'anything' },
        headers: { 'HTTP_HOST' => 'acme.localhost' }

    expect(response).to redirect_to(new_user_session_url(host: 'acme.localhost'))
  end
end
