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

  # 303 rather than the 302 this asserted before Devise's responder was
  # configured. Turbo Drive follows a redirect with fetch, which downgrades a
  # 302 to GET only when the request was a POST - a PATCH or PUT keeps its
  # method and arrives at an action that does not answer it. 303 says "GET the
  # other thing" for every method, which is why it is what Turbo wants.
  it 'signs in with the right password' do
    sign_in_as('employee@example.com')
    expect(response).to have_http_status(:see_other)

    get '/dashboard', headers: host
    expect(response).to have_http_status(:ok)
  end

  # The other half of the same setting, and the one with something to lose.
  # Devise still defaults error_status to :ok, and Turbo Drive throws away a
  # 200 answer to a form submission - so on the default the sign-in page would
  # answer a wrong password with a body the browser never renders, leaving the
  # form sitting there having apparently done nothing.
  it 'refuses the wrong password with a status Turbo will render' do
    sign_in_as('employee@example.com', password: 'wrong-password')

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include(I18n.t('devise.failure.invalid', authentication_keys: 'email'))

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
