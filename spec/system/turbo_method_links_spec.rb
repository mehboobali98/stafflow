# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'the links that are not GETs', type: :system do
  let!(:company) { create(:company, subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }
  let!(:owner) do
    as_tenant(company) { create(:user, :account_owner, company: company, email: 'owner@example.com') }
  end

  it 'signs out from the sidebar' do
    sign_in_as(company, owner)

    find("a[href*='sign_out']").click
    expect(page).to have_current_path(root_path)

    visit_tenant(company, dashboard_path)

    expect(page).to have_current_path(new_user_session_path)
  end

  it 'generates a payroll from the link that posts' do
    employee = as_tenant(company) do
      create(:user, :employee, company: company, department: department, email: 'employee@example.com')
    end
    sign_in_as(company, owner)
    visit_tenant(company, member_payrolls_path(employee))

    accept_confirm { click_on I18n.t('payroll.button.generate_payroll') }

    expect(page).to have_content(I18n.t('payroll.messages.success.create'))
    expect(as_tenant(company) { employee.payrolls.count }).to eq 1
  end
end
