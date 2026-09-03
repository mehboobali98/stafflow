# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'the events calendar', type: :system do
  let!(:company) { create(:company, subdomain: 'acme') }
  let!(:owner) do
    as_tenant(company) { create(:user, :account_owner, company: company, email: 'owner@example.com') }
  end

  before { sign_in_as(company, owner) }

  it 'moves to the next month without reloading the page around it' do
    visit_tenant(company, display_calendar_events_path)
    this_month = I18n.t('date.month_names')[Date.current.month]
    expect(page).to have_css('.calendar-title', text: this_month)
    page.execute_script("document.querySelector('.sidebar').dataset.probe = 'kept'")

    find('.calendar-heading a:last-of-type').click

    next_month = I18n.t('date.month_names')[Date.current.next_month.month]
    expect(page).to have_css('.calendar-title', text: next_month)
    expect(page.evaluate_script("document.querySelector('.sidebar').dataset.probe")).to eq 'kept'
  end
end
