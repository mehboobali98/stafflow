# frozen_string_literal: true

require 'rails_helper'

# These began as six pages each loading a JavaScript bundle of its own, none of
# them reached by anything that ran it. The bundles are Stimulus controllers
# now and the pages load nothing extra, so what an example asserts is the one
# thing its page does - which is what it was asserting before, and the reason
# the conversion could be made without rewriting them. `js_errors: true` covers
# the other half: a throw on load fails the example wherever it happens.
RSpec.describe 'what each page does', type: :system do
  let!(:company) { create(:company, subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }
  let!(:owner) do
    as_tenant(company) { create(:user, :account_owner, company: company, email: 'owner@example.com') }
  end
  let!(:employee) do
    as_tenant(company) do
      create(:user, :employee, company: company, department: department, email: 'employee@example.com')
    end
  end

  # The subdomain controller slugs the company name as it is typed. This ran
  # twice before it was one controller - signup.js on this page and the same
  # code again at the top of user.js, which every page loads.
  # It is also the only example here on the apex host, and the only one signed out.
  it 'slugs the subdomain from the company name on the sign-up page' do
    visit_apex new_user_registration_path
    fill_in 'company', with: 'Wayne Enterprises!'

    expect(page).to have_field('subdomain', with: 'wayneenterprises', visible: :all)
    expect(page).to have_css('#span_subdomain', text: 'wayneenterprises')
  end

  context 'when signed in' do
    before { sign_in_as(company, owner) }

    # The dirty-form controller leaves the submit disabled until something
    # changes. The button is rendered disabled, so this is the enabling half.
    it 'enables the settings submit once the form is touched' do
      visit_tenant(company, settings_path)
      expect(page).to have_button(disabled: true)

      fill_in 'setting_tax_rate', with: '12'

      expect(page).to have_button(disabled: false)
    end

    # notifications.js is still a bundle: its filter and pagination fetch
    # `.js.erb`, so it converts with those rather than here.
    it 'disables the mark-as-read button on the notifications page' do
      visit_tenant(company, notifications_path)

      expect(page).to have_css('#read-button[disabled]')
    end

    # The event-date controller binds a submit handler; nothing is asserted
    # about the alert it raises, only that the form is there to carry it.
    it 'renders the event form with its date handler attached' do
      visit_tenant(company, new_event_path)

      expect(page).to have_css('#event_form')
    end

    # The toggle-field controller enables the count beside whichever leave is
    # ticked. The same controller does the benefits table further down - two
    # bundles that had written the same behaviour twice.
    it 'enables a leave count when its row is ticked' do
      as_tenant(company) { create(:leave, company: company, name: 'Annual') }
      visit_tenant(company, new_member_user_leave_path(employee))
      expect(page).to have_css('input[disabled].js-leave-count-1, input[disabled]')

      first('.js-available-user-leave').click

      expect(page).to have_no_css('input.js-leave-count-1[disabled]')
    end

    # user.js is still bundled into application.js, so it runs on every page,
    # but the only thing exercising this path is the employee form: picking a
    # department fetches that department's designations into the select beside
    # it. The request asks for JSON from an endpoint that answers only JSON,
    # which is not what it did before jQuery 4.
    it 'fills the designations from the department picked' do
      as_tenant(company) do
        designation = create(:designation, company: company, department: department,
                                           name: 'Staff Engineer')
        designation.department
      end
      visit_tenant(company, new_member_path)

      select department.name, from: 'department_select'

      expect(page).to have_css('#designation_select option', text: 'Staff Engineer')
    end

    # The same controller again, on the amount beside a benefit.
    it 'enables a benefit amount when its row is ticked' do
      benefit = as_tenant(company) { create(:benefit, company: company) }
      visit_tenant(company, available_benefits_member_users_benefits_path(employee))
      expect(page).to have_css("#number_field_#{benefit.id}[disabled]")

      first('.new_user_benefit').click

      expect(page).to have_no_css("#number_field_#{benefit.id}[disabled]")
    end

    # The sidebar collapse had no spec at all. It is on every signed-in page,
    # and its two halves are rendered by two different templates, so it is the
    # one behaviour here that a spec has to see assembled to see working.
    it 'widens the sidebar and the content beside it when toggled' do
      visit_tenant(company, dashboard_path)
      expect(page).to have_no_css('.sidebar.expanded')

      find_by_id('sidebar_toggle_btn').click

      expect(page).to have_css('.sidebar.expanded')
      expect(page).to have_css('.home-content.expanded')
    end

    # The notification badge had no spec either. It is filled in from a request
    # the page makes for itself, so an empty badge is what a broken route looks
    # like - which is why the URL is now written by the route helper.
    it 'fills the notification badge from the count endpoint' do
      as_tenant(company) do
        create_list(:notification, 2, company: company, recipient: owner, status: false)
      end
      visit_tenant(company, dashboard_path)

      expect(page).to have_css('#notifications_count', text: '2')
    end
  end
end
