# frozen_string_literal: true

require 'rails_helper'

# The two rescue_from handlers in ApplicationController are the app's whole
# error surface for signed-in traffic, so what they answer with is worth
# pinning down: a real status code, and a page that has been through ERB.
RSpec.describe 'error handling', type: :request do
  let!(:company)   { create(:company, subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }

  let!(:employee) do
    as_tenant(company) do
      create(:user, :employee, company: company, department: department,
                               email: 'employee@example.com', password: 'password123')
    end
  end

  def host
    { 'HTTP_HOST' => 'acme.localhost' }
  end

  before do
    post '/users/sign_in',
         params: { user: { email: 'employee@example.com', password: 'password123' } },
         headers: host
  end

  describe 'a resource the signed-in user may not see' do
    # Company settings are the account owner's and HR's; an employee reaching
    # them raises CanCan::AccessDenied.
    it 'answers 403 rather than 200' do
      get '/settings', headers: host

      expect(response).to have_http_status(:forbidden)
    end

    it 'renders the page through ERB rather than as raw source' do
      get '/settings', headers: host

      expect(response.body).not_to include('<%=')
      expect(response.body).to include('<!DOCTYPE html>')
    end

    # The denial page is its own template rather than the 401 one, so its
    # title matches the status the response actually carries.
    it 'renders the forbidden page rather than the unauthorized one' do
      get '/settings', headers: host

      expect(response.body).to include('403')
      expect(response.body).not_to include('401 Error')
    end
  end

  # config.exceptions_app is the router, so these paths are what Rails falls
  # back to for an unhandled response. /404 and /500 are deliberately absent:
  # public/404.html and public/500.html shadow them whenever the static file
  # server is enabled, which it always is in test. See ROADMAP.md.
  describe 'the error routes used by exceptions_app' do
    { '/401' => :unauthorized, '/403' => :forbidden }.each do |path, status|
      it "serves #{path} as #{status}" do
        get path, headers: host

        expect(response).to have_http_status(status)
      end
    end
  end

  describe 'a record that does not exist' do
    it 'answers 404 rather than 200' do
      get "/members/#{employee.id}/applied_leaves/999999/edit", headers: host

      expect(response).to have_http_status(:not_found)
    end
  end
end
