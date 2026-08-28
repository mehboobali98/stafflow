# frozen_string_literal: true

require 'rails_helper'

# These go through the full stack, so they cover the part the model specs
# cannot: ApplicationController resolving the tenant from the request
# subdomain and clearing it again afterwards.
RSpec.describe 'tenant resolution', type: :request do
  let!(:acme) { create(:company, name: 'Acme', subdomain: 'acme') }

  def get_with_host(host, path = '/')
    get path, headers: { 'HTTP_HOST' => host }
  end

  it 'serves the marketing page with no subdomain' do
    get_with_host('localhost')
    expect(response).to have_http_status(:ok)
  end

  it 'resolves a known subdomain to its company' do
    get_with_host('acme.localhost', '/users/sign_in')
    expect(response).to have_http_status(:ok)
  end

  it 'renders the not-found page for a subdomain that belongs to no company' do
    get_with_host('nosuchtenant.localhost', '/users/sign_in')

    expect(response.body).to include('404')
  end

  # ApplicationController used to rescue RecordNotFound with
  #   render file: 'app/views/errors/not_found.html'
  # which sets no status, so a missing tenant answered 200 OK. Anything
  # consuming this app programmatically could not tell success from failure.
  it 'answers 404 for an unknown subdomain' do
    get_with_host('nosuchtenant.localhost', '/users/sign_in')

    expect(response).to have_http_status(:not_found)
  end

  it 'renders the not-found page through ERB rather than as raw source' do
    get_with_host('nosuchtenant.localhost', '/users/sign_in')

    expect(response.body).not_to include('<%=')
  end

  it 'leaves no tenant set once the request is finished' do
    get_with_host('acme.localhost', '/users/sign_in')
    expect(Company.current_company_id).to be_nil
  end

  it 'clears the tenant even when resolution fails' do
    get_with_host('nosuchtenant.localhost', '/users/sign_in')

    expect(Company.current_company_id).to be_nil
  end
end
