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

  # Populated rather than empty, because an empty table cannot overflow and
  # would report success for a page that has never been measured.
  before do
    as_tenant(company) do
      department = create(:department, company: company, name: 'Engineering')
      create(:designation, company: company, department: department, name: 'Staff Engineer')
      create(:leave, company: company, name: 'Annual')
      create(:benefit, company: company)
      create(:event, company: company, name: 'All hands', starts_at: 2.days.from_now)
      create(:notification, company: company, recipient: owner, body: 'Leave approved')
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

  {
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
  }.each do |name, path|
    it "renders #{name} without scrolling sideways" do
      visit_narrow(owner, path)

      expect(overflows_horizontally?).to be false
    end
  end

  it 'renders the leave queue without scrolling sideways' do
    visit_narrow(owner, all_applied_leaves_path)

    expect(overflows_horizontally?).to be false
  end

  describe 'the member-scoped pages' do
    let!(:employee) do
      as_tenant(company) do
        create(:user, :employee, company: company, department: Department.first, email: 'grace@example.com')
      end
    end

    before do
      as_tenant(company) do
        create(:payroll, company: company, user: employee)
        user_leave = create(:user_leave, company: company, user: employee)
        create(:applied_leave, company: company, user_leave: user_leave)
        create(:users_benefit, company: company, user: employee)
      end
    end

    {
      'the payroll list' => :member_payrolls_path,
      'the leave allowance list' => :member_user_leaves_path,
      'the benefit allocation list' => :member_users_benefits_path,
      'the available benefits form' => :available_benefits_member_users_benefits_path
    }.each do |name, helper|
      it "renders #{name} without scrolling sideways" do
        visit_narrow(owner, public_send(helper, employee))

        expect(overflows_horizontally?).to be false
      end
    end

    # The account owner cannot read an AppliedLeave - it has approve and reject
    # but no :read - so this one is measured as HR. Visited as the owner it
    # answers 403, and an error page fits at 390px, which is exactly the false
    # pass the .page-shell wait in visit_narrow exists to catch.
    it 'renders the applied leave list without scrolling sideways' do
      visit_narrow(hr, member_applied_leaves_path(employee))

      expect(overflows_horizontally?).to be false
    end
  end

  describe 'the resource forms' do
    {
      'the department form' => :new_department_path,
      'the designation form' => :new_designation_path,
      'the leave form' => :new_leave_path,
      'the benefit form' => :new_benefit_path,
      'the event form' => :new_event_path
    }.each do |name, helper|
      it "renders #{name} without scrolling sideways" do
        visit_narrow(owner, public_send(helper))

        expect(overflows_horizontally?).to be false
      end
    end
  end

  it 'renders the HR leave form without scrolling sideways' do
    visit_narrow(hr, new_applied_leave_by_hr_applied_leaves_path)

    expect(overflows_horizontally?).to be false
  end
end
