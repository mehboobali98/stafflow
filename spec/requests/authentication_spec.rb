# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'authentication', type: :request do
  let!(:company)    { create(:company, subdomain: 'acme') }
  let(:department)  { as_tenant(company) { create(:department, company: company) } }
  let!(:employee) do
    as_tenant(company) do
      create(:user, :employee, company: company, department: department,
                               email: 'employee@example.com', password: 'password123')
    end
  end

  def host
    { 'HTTP_HOST' => 'acme.localhost' }
  end

  def sign_in_as(email, password: 'password123')
    post '/users/sign_in',
         params: { user: { email: email, password: password } },
         headers: host
  end

  it 'redirects an anonymous visitor away from the dashboard' do
    get '/dashboard', headers: host
    expect(response).to redirect_to(new_user_session_url(host: 'acme.localhost'))
  end

  it 'signs in with the right password' do
    sign_in_as('employee@example.com')
    expect(response).to have_http_status(:found)

    get '/dashboard', headers: host
    expect(response).to have_http_status(:ok)
  end

  it 'refuses the wrong password' do
    sign_in_as('employee@example.com', password: 'wrong-password')

    get '/dashboard', headers: host
    expect(response).not_to have_http_status(:ok)
  end

  it 'refuses an account from another company on this subdomain' do
    other = create(:company, subdomain: 'globex')
    as_tenant(other) do
      other_department = create(:department, company: other)
      create(:user, :employee, company: other, department: other_department,
                               email: 'outsider@example.com', password: 'password123')
    end

    sign_in_as('outsider@example.com')

    get '/dashboard', headers: host
    expect(response).not_to have_http_status(:ok)
  end
end
