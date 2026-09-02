# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'the index pages', type: :request do
  let!(:company) { create(:company, subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }
  let!(:owner) do
    as_tenant(company) { create(:user, :account_owner, company: company, email: 'owner@example.com') }
  end

  def host
    { 'HTTP_HOST' => 'acme.localhost' }
  end

  before do
    post '/users/sign_in',
         params: { user: { email: owner.email, password: 'password123' } },
         headers: host
  end

  paths = {
    'the dashboard' => '/dashboard',
    'the employee list' => '/members',
    'the department list' => '/departments',
    'the designation list' => '/designations',
    'the leave list' => '/leaves',
    'the event list' => '/events',
    'the benefit list' => '/benefits',
    'the notification list' => '/notifications',
    'the settings page' => '/settings',
    'the analytics page' => '/analytics'
  }.freeze

  context 'with nothing in them' do
    paths.each do |name, path|
      it "renders #{name}" do
        get path, headers: host

        expect(response).to have_http_status(:ok)
      end
    end
  end

  context 'with a row in each' do
    before do
      as_tenant(company) do
        create(:designation, company: company, department: department, name: 'Staff Engineer')
        create(:leave, company: company, name: 'Annual')
        create(:benefit, company: company)
        create(:event, company: company, name: 'All hands', starts_at: 2.days.from_now)
        create(:notification, company: company, recipient: owner)
      end
    end

    paths.each do |name, path|
      it "renders #{name}" do
        get path, headers: host

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
