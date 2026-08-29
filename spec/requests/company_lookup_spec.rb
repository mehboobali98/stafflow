# frozen_string_literal: true

require 'rails_helper'

# Sign-in starts on the apex host: a visitor gives an email, and the application
# hands them on to their own tenant. That hop crosses hosts, and it is the only
# cross-host redirect the application makes, which is what earns it a spec of
# its own - Rails 7.0's `raise_on_open_redirects` refuses exactly this shape of
# `redirect_to` unless it is marked as deliberate.
RSpec.describe 'company lookup from the apex host', type: :request do
  let!(:acme) { create(:company, name: 'Acme', subdomain: 'acme') }

  def look_up(email)
    get '/home/display_companies',
        params: { user: { email: email } },
        headers: { 'HTTP_HOST' => 'localhost' }
  end

  def employee_of(company, email)
    department = as_tenant(company) { create(:department, company: company) }

    as_tenant(company) do
      create(:user, :employee, company: company, department: department, email: email)
    end
  end

  it 'sends a visitor with one company to that company sign-in page' do
    employee_of(acme, 'employee@example.com')

    look_up('employee@example.com')

    expect(response).to redirect_to(
      new_user_session_url(host: 'acme.localhost', email: 'employee@example.com')
    )
  end

  it 'offers the choice when the email belongs to more than one company' do
    globex = create(:company, name: 'Globex', subdomain: 'globex')
    employee_of(acme, 'shared@example.com')
    employee_of(globex, 'shared@example.com')

    look_up('shared@example.com')

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('acme.localhost').and include('globex.localhost')
  end

  it 'says so when the email belongs to no company' do
    look_up('nobody@example.com')

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(I18n.t('labels.nocompanies'))
  end
end
