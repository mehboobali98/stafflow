# frozen_string_literal: true

require 'rails_helper'

# The HR-facing form is reached from the company-wide leave list, not from a
# member, so nothing in the request carries a member id.
RSpec.describe 'applied leaves added by HR', type: :request do
  let!(:company)   { create(:company, subdomain: 'acme') }
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

  describe 'GET /applied_leaves/new_applied_leave_by_hr' do
    # The controller-wide breadcrumb points at member_applied_leaves_path, which
    # cannot be generated without a member id. It was excluded from
    # all_applied_leaves but not from this action, so rendering the layout
    # raised and the page 500d for the only role that can reach it.
    it 'renders for HR' do
      get '/applied_leaves/new_applied_leave_by_hr', headers: host

      expect(response).to have_http_status(:ok)
    end
  end
end
