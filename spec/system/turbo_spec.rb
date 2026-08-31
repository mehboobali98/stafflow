# frozen_string_literal: true

require 'rails_helper'

# Nothing in the rest of the suite navigates. Every other system spec calls
# `visit`, which is a full page load whether Turbo is on the page or not - so
# all 292 examples stayed green with turbolinks swapped for Turbo underneath
# them, and would have stayed green with neither. These examples exist to make
# the swap falsifiable: each one fails if Turbo is not driving, and the
# form ones fail if the statuses it needs are not being sent.
RSpec.describe 'Turbo Drive', type: :system do
  let!(:company) { create(:company, subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }
  let!(:owner) do
    as_tenant(company) { create(:user, :account_owner, company: company, email: 'owner@example.com') }
  end

  # A full page load discards `window`; a Turbo visit replaces the body and
  # keeps it. So a value stamped on `window` before the click and still there
  # after it is the difference between the two, and it is the only assertion
  # here that a page merely rendering could not also satisfy.
  def mark_this_page
    page.execute_script('window.__notReloaded = true')
  end

  def page_was_kept?
    page.evaluate_script('window.__notReloaded === true')
  end

  describe 'navigation' do
    before { sign_in_as(company, owner) }

    it 'follows a link without reloading the document' do
      visit_tenant(company, dashboard_path)
      mark_this_page

      click_on I18n.t('sidebar.departments')

      expect(page).to have_current_path(departments_path)
      expect(page_was_kept?).to be true
    end

    it 'restores the previous page on a back navigation' do
      visit_tenant(company, dashboard_path)
      click_on I18n.t('sidebar.departments')
      expect(page).to have_current_path(departments_path)
      mark_this_page

      page.go_back

      expect(page).to have_current_path(dashboard_path)
      expect(page_was_kept?).to be true
    end
  end

  describe 'a form whose submission fails validation' do
    before { sign_in_as(company, owner) }

    # The settings form is the one that can fail server-side without the
    # browser stopping it first: tax_rate carries min and max attributes, but
    # leave_resets_at is only checked in Ruby, where it has to be in the future.
    #
    # Turbo throws a 200 answer to a form submission away without rendering it,
    # so before settings#update said :unprocessable_content this submission
    # left the page exactly as it was, with no error anywhere and no console
    # message either.
    it 'renders the errors it comes back with' do
      visit_tenant(company, settings_path)

      fill_in 'setting_leave_resets_at', with: Date.current.prev_year
      click_on 'Save Setting'

      expect(page).to have_css('.flash-message', text: I18n.t('leave_error'))
      # The form posts to /settings/:id, and Turbo renders a 4xx body without
      # moving the address bar - so a failed edit leaves you on the page you
      # were editing rather than on the action's own URL.
      expect(page).to have_current_path(settings_path)
    end
  end

  describe 'a form whose submission succeeds' do
    before { sign_in_as(company, owner) }

    it 'follows the redirect and lands on the page it names' do
      visit_tenant(company, new_department_path)

      fill_in 'department_name', with: 'Radiology'
      click_on I18n.t('department.add_message')

      expect(page).to have_current_path(departments_path)
      expect(page).to have_content('Radiology')
    end
  end

  # Devise defaults error_status to :ok, which Turbo discards. This is the
  # front door of the application, so it gets an example of its own rather
  # than resting on the request spec that asserts the status.
  describe 'signing in with the wrong password' do
    it 'shows the failure message rather than an unchanged form' do
      visit_tenant(company, new_user_session_path)
      fill_in 'user_email', with: owner.email
      fill_in 'user_password', with: 'not-the-password'
      click_on I18n.t('forms.buttons.signin')

      expect(page).to have_content(I18n.t('devise.failure.invalid', authentication_keys: 'email'))
    end
  end

  # rails-ujs is still here - it is what drives the `.js.erb` responses and the
  # data-method links, and it leaves with jQuery in the Stimulus step rather
  # than here. Both libraries want the same clicks, and the arrangement that
  # keeps them apart is structural rather than lucky: ujs delegates on
  # document, Turbo's link observer is on window, so ujs sees a click first and
  # stops it propagating; and Turbo's form observer skips any submit event
  # whose default was already prevented, which is what ujs does to a remote
  # form. This example is what would notice if that stopped being true.
  describe 'alongside rails-ujs' do
    let!(:doomed) { as_tenant(company) { create(:department, company: company, name: 'Obsolete') } }

    before { sign_in_as(company, owner) }

    it 'still deletes through a data-method link' do
      visit_tenant(company, departments_path)
      expect(page).to have_content('Obsolete')

      # Scoped to the row: the sidebar's sign-out is a data-method link too.
      row = find('tr', text: 'Obsolete')
      accept_confirm { row.find("a[data-method='delete']").click }

      expect(page).to have_no_content('Obsolete')
      expect(as_tenant(company) { Department.exists?(doomed.id) }).to be false
    end
  end
end
