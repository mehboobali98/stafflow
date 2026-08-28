# frozen_string_literal: true

require 'rails_helper'

# The update action guards on the leave year and the remaining balance before
# attempting the update, so reaching the failure branch takes a request that
# clears both guards and then fails model validation.
RSpec.describe 'applied leaves', type: :request do
  let!(:company)   { create(:company, subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }

  let!(:employee) do
    as_tenant(company) do
      create(:user, :employee, company: company, department: department,
                               email: 'employee@example.com', password: 'password123')
    end
  end

  let!(:applied_leave) do
    as_tenant(company) do
      user_leave = create(:user_leave, company: company, user: employee, remaining_count: 20.0)
      create(:applied_leave, company: company, user_leave: user_leave)
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

  describe 'PATCH /members/:member_id/applied_leaves/:id' do
    def update_with(params)
      patch "/members/#{employee.id}/applied_leaves/#{applied_leave.id}",
            params: { applied_leave: params }, headers: host
    end

    it 'applies a valid change' do
      update_with(applied_till: applied_leave.applied_from + 1)

      expect(response).to redirect_to(member_applied_leaves_url(employee, host: 'acme.localhost'))
      expect(flash[:notice]).to be_present
    end

    # The failure branch read `@leave.errors`, but the action only ever assigns
    # `@applied_leave`, so any leave whose update failed validation raised
    # NoMethodError on nil instead of showing the validation message.
    it 'reports the error instead of raising when the update is invalid' do
      expect { update_with(applied_till: '') }.not_to raise_error
    end

    it 'redirects back to the form with the validation message' do
      update_with(applied_till: '')

      expect(response).to redirect_to(
        edit_member_applied_leave_url(employee, applied_leave, host: 'acme.localhost')
      )
      expect(flash[:error]).to be_present
    end

    it 'leaves the record unchanged when the update is invalid' do
      expect { update_with(applied_till: '') }
        .not_to(change { applied_leave.reload.applied_till })
    end
  end
end
