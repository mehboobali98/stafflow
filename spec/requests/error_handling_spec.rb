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
  end

  describe 'a record that does not exist' do
    it 'answers 404 rather than 200' do
      get "/members/#{employee.id}/applied_leaves/999999/edit", headers: host

      expect(response).to have_http_status(:not_found)
    end
  end
end
