# frozen_string_literal: true

require 'rails_helper'

# The department-to-designation cascade had no browser coverage at all while it
# was jQuery: it fetched from an endpoint answering JSON with `dataType:
# 'script'`, 404ed on every call from the jquery 4 bump onward, and left the
# designation select empty without throwing.
RSpec.describe 'a select that depends on another', type: :system do
  let!(:company) { create(:company, subdomain: 'acme') }
  let!(:engineering) { as_tenant(company) { create(:department, company: company, name: 'Engineering') } }
  let!(:finance) { as_tenant(company) { create(:department, company: company, name: 'Finance') } }
  let!(:owner) do
    as_tenant(company) { create(:user, :account_owner, company: company, email: 'owner@example.com') }
  end

  before do
    as_tenant(company) do
      create(:designation, company: company, department: engineering, name: 'Staff Engineer')
      create(:designation, company: company, department: finance, name: 'Controller')
    end
    sign_in_as(company, owner)
    visit_tenant(company, new_member_path)
  end

  it 'ships the designation select empty' do
    expect(page).to have_css('#designation_select')
    expect(page).to have_css('#designation_select option', count: 1, text: I18n.t('forms.labels.designation'))
  end

  it 'fills the designations of the department chosen' do
    select 'Engineering', from: 'department_select'

    expect(page).to have_css('#designation_select option', text: 'Staff Engineer')
    expect(page).to have_no_css('#designation_select option', text: 'Controller')
  end

  it 'replaces them rather than appending when the department changes again' do
    select 'Engineering', from: 'department_select'
    expect(page).to have_css('#designation_select option', text: 'Staff Engineer')

    select 'Finance', from: 'department_select'

    expect(page).to have_css('#designation_select option', text: 'Controller')
    expect(page).to have_css('#designation_select option', count: 1)
    expect(page).to have_no_css('#designation_select option', text: 'Staff Engineer')
  end

  def fill_in_the_rest_of_the_employee
    fill_in 'user_email', with: 'new.hire@example.com'
    fill_in 'first_name', with: 'New'
    fill_in 'user_last_name', with: 'Hire'
    fill_in 'user_date_of_birth', with: '1990-01-01'
    fill_in 'user_base_salary', with: '50000'
    select I18n.t('user_roles.employee'), from: 'user_role_id'
    select I18n.t('user_genders.female'), from: 'user_gender'
  end

  # The DOM being right is not the same as the value submitting. Nothing else in
  # the suite carries a cascade-filled option through to a saved record.
  it 'submits the designation the cascade filled in' do
    fill_in_the_rest_of_the_employee
    select 'Engineering', from: 'department_select'
    expect(page).to have_css('#designation_select option', text: 'Staff Engineer')
    select 'Staff Engineer', from: 'designation_select'

    click_on I18n.t('forms.buttons.create')

    expect(page).to have_current_path(members_path)
    designation = as_tenant(company) do
      User.find_by(email: 'new.hire@example.com').designation
    end
    expect(designation.name).to eq('Staff Engineer')
  end
end
