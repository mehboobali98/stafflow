# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'the dashboard', type: :system do
  let!(:company) { create(:company, name: 'Acme Corporation', subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }
  let!(:owner) do
    as_tenant(company) { create(:user, :account_owner, company: company, email: 'owner@example.com') }
  end

  before do
    # The charts group employees by department and by city. Chartkick renders
    # its empty message rather than a canvas when the endpoint answers {}, so
    # there has to be someone to count.
    as_tenant(company) do
      create(:user, :employee, company: company, department: department, city: 'Lahore')
    end
    sign_in_as(company, owner)
  end

  it 'signs in through the subdomain and lands on the dashboard' do
    expect(page).to have_current_path(dashboard_path)
  end

  # Chartkick here points at JSON endpoints rather than at inline data, so a
  # canvas exists only if the bundle booted, the request went out under the
  # tenant the session resolved, and Chart.js drew what came back.
  it 'draws both charts from their JSON endpoints' do
    expect(page).to have_css('canvas', count: 2)
  end
end
