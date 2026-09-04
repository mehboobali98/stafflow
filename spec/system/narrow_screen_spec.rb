# frozen_string_literal: true

require 'rails_helper'

# PR #71 gave the layouts a <meta name="viewport">, which the application had
# never carried. Until then a phone rendered at roughly 980px and scaled down,
# so nothing in 121 views had ever reflowed. Turning it on makes narrow-screen
# rendering real for the first time, and gives the page-by-page rebuild a
# measurable finish line: a page is done when it does not overflow horizontally
# at 390px. Pages join this list as they are rebuilt from components.
RSpec.describe 'the pages at 390px', type: :system do
  let!(:company) { create(:company, subdomain: 'acme') }
  let!(:owner) do
    as_tenant(company) { create(:user, :account_owner, company: company, email: 'owner@example.com') }
  end
  let!(:hr) do
    as_tenant(company) { create(:user, :hr, company: company, email: 'hr@example.com') }
  end

  before do
    as_tenant(company) do
      department = create(:department, company: company, name: 'Engineering')
      create(:user, :employee, company: company, department: department, email: 'ada@example.com')
    end
  end

  # scrollWidth exceeding clientWidth on the documentElement is the whole test:
  # it asks whether the document itself scrolls sideways, which is what a phone
  # user feels. Content wider than the screen inside its own scroll container -
  # a table in .table-responsive - is not overflow and does not count here.
  def overflows_horizontally?
    page.evaluate_script(
      'document.documentElement.scrollWidth > document.documentElement.clientWidth'
    )
  end

  def visit_narrow(user, path)
    sign_in_as(company, user)
    page.driver.resize(390, 844)
    visit_tenant(company, path)
    find('.page-shell')
  end

  # Each of these was rebuilt from components, and each is the page that item
  # of phase 7 was the proof for.
  {
    'the dashboard' => :dashboard_path,
    'the employee list' => :members_path,
    'the leave queue' => :all_applied_leaves_path,
    'the settings page' => :settings_path
  }.each do |name, helper|
    it "renders #{name} without scrolling sideways" do
      visit_narrow(owner, public_send(helper))

      expect(overflows_horizontally?).to be false
    end
  end

  it 'renders the HR leave form without scrolling sideways' do
    visit_narrow(hr, new_applied_leave_by_hr_applied_leaves_path)

    expect(overflows_horizontally?).to be false
  end
end
