# frozen_string_literal: true

require 'rails_helper'

# The session cookie is host-only, and tenants live on subdomains. That makes
# the host a sign-out request is sent to part of whether it works at all, which
# is not obvious from reading the controller - so this follows the link the
# application actually renders rather than a path built here.
RSpec.describe 'signing out', type: :request do
  let!(:company) { create(:company, subdomain: 'acme') }

  before do
    as_tenant(company) do
      create(:user, :account_owner, company: company, email: 'owner@example.com')
    end

    host! 'acme.localhost'
    post '/users/sign_in',
         params: { user: { email: 'owner@example.com', password: 'password123' } }
  end

  def logout_link_from_dashboard
    host! 'acme.localhost'
    get '/dashboard'
    expect(response).to have_http_status(:ok)

    response.body[%r{href="([^"]*users/sign_out[^"]*)"}, 1]
  end

  it 'offers a logout link on the tenant host, where the session cookie lives' do
    expect(logout_link_from_dashboard).to start_with('http://acme.localhost')
  end

  it 'ends the session when that link is followed' do
    uri = URI.parse(logout_link_from_dashboard)

    # host! rather than an HTTP_HOST header: rack-test files cookies against
    # the session's host, so only this makes the jar treat the apex and the
    # tenant as the separate origins a browser sees.
    host! uri.host
    delete uri.path

    host! 'acme.localhost'
    get '/dashboard'
    expect(response).to redirect_to(new_user_session_url(host: 'acme.localhost'))
  end

  # Sign-out lands on `root_path` - home#index, on the signup layout, which
  # rendered no flash partial at all. The notice devise raises had nowhere to go.
  it 'renders the notice on the page it lands on' do
    delete '/users/sign_out'
    follow_redirect!

    expect(response.body).to include(I18n.t('devise.sessions.signed_out'))
  end
end
