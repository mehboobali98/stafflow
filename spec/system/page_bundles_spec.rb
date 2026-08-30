# frozen_string_literal: true

require 'rails_helper'

# Six pages load a JavaScript bundle of their own, and until now none of them
# were reached by anything that runs it. Each example below asserts the one
# thing its bundle does, so a bundle that stops running is a failure rather
# than a page that merely still renders. `js_errors: true` covers the other
# half: a throw on load fails the example wherever it happens.
RSpec.describe 'the pages that carry their own bundle', type: :system do
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

  # signup.js slugs the company name into the subdomain field as it is typed.
  # This is the only one of the six on the apex host and the only one signed out.
  it 'slugs the subdomain from the company name on the sign-up page' do
    visit_apex new_user_registration_path
    fill_in 'company', with: 'Wayne Enterprises!'

    expect(page).to have_field('subdomain', with: 'wayneenterprises', visible: :all)
    expect(page).to have_css('#span_subdomain', text: 'wayneenterprises')
  end

  context 'when signed in' do
    before { sign_in_as(company, owner) }

    # settings.js leaves the submit button disabled until something changes.
    it 'enables the settings submit once the form is touched' do
      visit_tenant(company, settings_path)
      expect(page).to have_button(disabled: true)

      fill_in 'setting_tax_rate', with: '12'

      expect(page).to have_button(disabled: false)
    end

    # notifications.js disables its button until a row is checked.
    it 'disables the mark-as-read button on the notifications page' do
      visit_tenant(company, notifications_path)

      expect(page).to have_css('#read-button[disabled]')
    end

    # event.js binds a submit handler that validates the date; nothing is
    # asserted about the alert it raises, only that the bundle got that far.
    it 'renders the event form with its bundle running' do
      visit_tenant(company, new_event_path)

      expect(page).to have_css('#event_form')
    end

    # user_leaves.js enables the count field beside whichever leave is ticked.
    it 'enables a leave count when its row is ticked' do
      as_tenant(company) { create(:leave, company: company, name: 'Annual') }
      visit_tenant(company, new_member_user_leave_path(employee))
      expect(page).to have_css('input[disabled].js-leave-count-1, input[disabled]')

      first('.js-available-user-leave').click

      expect(page).to have_no_css('input.js-leave-count-1[disabled]')
    end

    # user.js is bundled into application.js, so it runs on every page, but the
    # only thing that exercises this path is the employee form: picking a
    # department fetches that department's designations into the select beside
    # it. The request behind it asks for JSON from an endpoint that answers
    # only JSON, which is not what it did before jQuery 4.
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

    # users_benefit_creation.js does the same for the amount beside a benefit.
    it 'enables a benefit amount when its row is ticked' do
      benefit = as_tenant(company) { create(:benefit, company: company) }
      visit_tenant(company, available_benefits_member_users_benefits_path(employee))
      expect(page).to have_css("#number_field_#{benefit.id}[disabled]")

      first('.new_user_benefit').click

      expect(page).to have_no_css("#number_field_#{benefit.id}[disabled]")
    end
  end
end
