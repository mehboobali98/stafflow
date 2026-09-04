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
         params: { user: { email: hr.email, password: 'password123' } },
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

    # create_applied_leave_by_hr answers format.html and redirects, so a remote
    # form submits over XHR, follows the redirect and leaves the page where it
    # was. Rails 6.1's form_with_generates_remote_forms default is what keeps
    # this form local; without it the submit button appears to do nothing.
    it 'renders the form local rather than remote' do
      get '/applied_leaves/new_applied_leave_by_hr', headers: host

      form = response.body[/<form[^>]*create_applied_leave_by_hr[^>]*>/]
      expect(form).not_to include('data-remote')
    end
  end

  # The combobox reads an id and an email off each record. `render json:` over
  # the relation sent every column Devise does not blacklist instead - base
  # salary, date of birth, gender and home city, for every employee matching
  # the query.
  describe 'GET /applied_leaves/search_users' do
    let!(:employee) do
      as_tenant(company) do
        create(:user, :employee, company: company, department: department,
                                 email: 'employee@example.com')
      end
    end

    it 'answers the matches' do
      get '/applied_leaves/search_users', params: { query: 'employee' },
                                          headers: host.merge('ACCEPT' => 'application/json')

      expect(response.parsed_body.map { |user| user['email'] }).to eq([employee.email])
    end

    it 'sends nothing but the id and the email' do
      get '/applied_leaves/search_users', params: { query: 'employee' },
                                          headers: host.merge('ACCEPT' => 'application/json')

      expect(response.parsed_body.first.keys).to match_array(%w[id email])
    end
  end
end
