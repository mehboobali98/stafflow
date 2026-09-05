# frozen_string_literal: true

require 'rails_helper'

# The forms moved to FormFieldComponent and ButtonComponent, which changes the
# markup around every control and replaces `form.submit` - an <input> - with a
# <button>. Label association is covered by forms_spec; what that cannot see is
# whether the value still reaches the database. The department form was already
# carried end to end by turbo_spec, and these are the six that were not.
RSpec.describe 'the resource forms', type: :system do
  let!(:company) { create(:company, subdomain: 'acme') }
  let!(:department) { as_tenant(company) { create(:department, company: company, name: 'Engineering') } }
  let!(:owner) do
    as_tenant(company) { create(:user, :account_owner, company: company, email: 'owner@example.com') }
  end
  let!(:employee) do
    as_tenant(company) do
      create(:user, :employee, company: company, department: department, email: 'ada@example.com')
    end
  end

  before { sign_in_as(company, owner) }

  it 'saves a designation, department and all' do
    visit_tenant(company, new_designation_path)
    fill_in 'designation_name', with: 'Staff Engineer'
    select 'Engineering', from: 'designation_department_id'

    click_on I18n.t('designation.add_message')

    # acts_as_tenant scopes associations, so `designation.department` has to be
    # inside the block too - not just the find_by that located the record.
    saved_department = as_tenant(company) do
      Designation.find_by(name: 'Staff Engineer')&.department
    end
    expect(saved_department).to eq(department)
  end

  it 'saves a leave type with its count' do
    visit_tenant(company, new_leave_path)
    fill_in 'leave_name', with: 'Sabbatical'
    fill_in 'leave_default_count', with: '15'

    click_on I18n.t('form.button.submit')

    leave = as_tenant(company) { Leave.find_by(name: 'Sabbatical') }
    expect(leave).to be_present
    expect(leave.default_count).to eq(15)
  end

  it 'saves a benefit with its amount' do
    visit_tenant(company, new_benefit_path)
    fill_in 'benefit_name', with: 'Dental'
    fill_in 'benefit_default_amount', with: '1250'

    click_on I18n.t('form.button.submit')

    benefit = as_tenant(company) { Benefit.find_by(name: 'Dental') }
    expect(benefit).to be_present
    expect(benefit.default_amount).to eq(1250)
  end

  it 'saves an event with the date and time typed into two fields' do
    visit_tenant(company, new_event_path)
    fill_in 'event_name', with: 'All hands'
    fill_in 'event_date', with: 1.month.from_now.to_date
    fill_in 'event_event_time', with: Time.zone.parse('09:30')

    click_on I18n.t('form.button.submit')

    event = as_tenant(company) { Event.find_by(name: 'All hands') }
    expect(event).to be_present
    expect(event.starts_at.strftime('%H:%M')).to eq('09:30')
  end

  it 'saves an applied leave against the allowance chosen in the select' do
    as_tenant(company) { create(:user_leave, company: company, user: employee) }
    sign_in_as(company, employee)
    visit_tenant(company, new_member_applied_leave_path(employee))

    # Leave counting only counts weekdays and an application cannot start in
    # the past, so both dates are pinned to the next upcoming weekday.
    weekday = Date.current + 1
    weekday += 1 while weekday.saturday? || weekday.sunday?
    fill_in 'applied_leave_applied_from', with: weekday
    fill_in 'applied_leave_applied_till', with: weekday

    click_on I18n.t('applied_leave.links.submit')

    applied = as_tenant(company) { AppliedLeave.find_by(user_id: employee.id) }
    expect(applied).to be_present
  end

  it 'saves an edited benefit allocation' do
    users_benefit = as_tenant(company) do
      create(:users_benefit, company: company, user: employee, amount: 5_000.0)
    end
    visit_tenant(company, edit_member_users_benefit_path(employee, users_benefit))

    fill_in 'users_benefit_amount', with: '7500'
    click_on I18n.t('form.button.submit')

    expect(users_benefit.reload.amount).to eq(7_500)
  end
end
