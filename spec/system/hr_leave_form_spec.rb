# frozen_string_literal: true

require 'rails_helper'

# The most jQuery-dependent page in the app, and the only place select2 is
# attached to a real element. Everything here runs through the global
# application.js puts on window: select2 registers against that jQuery, raises
# its own events on it, and the handlers answering those events live in a
# second bundle that reads it back off window.
RSpec.describe 'the HR leave form', type: :system do
  let!(:company) { create(:company, subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }
  let!(:hr) do
    as_tenant(company) do
      create(:user, :hr, company: company, department: department, email: 'hr@example.com')
    end
  end
  let!(:employee) do
    as_tenant(company) do
      user = create(:user, :employee, company: company, department: department,
                                      email: 'employee@example.com')
      create(:user_leave, company: company, user: user,
                          leave: create(:leave, company: company, name: 'Annual'))
      user
    end
  end

  # The select ships with no employees in it. Each keystroke in select2's search
  # field fires a request that appends the matches to the underlying select -
  # and select2 has already rendered its result list by the time they land, so
  # waiting for the append and then typing once more is what makes it re-filter
  # over what arrived. Without that second keystroke this races the AJAX.
  def search_for_the_employee
    find('.select2-selection').click
    field = find('.select2-search__field')
    field.send_keys('employee')
    expect(page).to have_css('#applied_leave_member_id option', text: employee.email, visible: :all)
    field.send_keys('@')
  end

  before do
    sign_in_as(company, hr)
    visit_tenant(company, new_applied_leave_by_hr_applied_leaves_path)
  end

  it 'replaces the member select with a select2 control' do
    expect(page).to have_css('.select2-container')
    expect(page).to have_css('#applied_leave_member_id.select2-hidden-accessible', visible: :all)
  end

  it 'searches employees through the control and appends what it finds' do
    search_for_the_employee

    expect(page).to have_css('.select2-results__option', text: employee.email)
  end

  # select2:select is select2's own event rather than a DOM one, so this fires
  # only if the library is driving the element and not merely loaded.
  it 'fills the leave types from the employee picked' do
    search_for_the_employee
    find('.select2-results__option', text: employee.email).click

    expect(page).to have_css('#leaves_select option', text: 'Annual')
  end
end
