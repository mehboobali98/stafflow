# frozen_string_literal: true

require 'rails_helper'

# The only page carrying both shapes of chart Chartkick offers: one handed its
# data inline by the view, one given a path and left to fetch it. The dashboard
# covers the remote shape alone, so without this a Chartkick major could break
# inline rendering with nothing to notice.
RSpec.describe 'the analytics page', type: :system do
  let!(:company) { create(:company, subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }
  let!(:hr) do
    as_tenant(company) do
      create(:user, :hr, company: company, department: department, email: 'hr@example.com')
    end
  end

  before do
    as_tenant(company) do
      create(:user, :employee, company: company, department: department, gender: 'Female')
      create(:user, :employee, company: company, department: department, gender: 'Male')
    end
    sign_in_as(company, hr)
    visit_tenant(company, analytics_path)
  end

  it 'draws both charts' do
    expect(page).to have_css('canvas', count: 2)
  end

  # Chartkick writes its own message into the container when it cannot draw -
  # a bad payload, or an adapter it could not find - and leaves the page at 200
  # with the card still in place. A canvas count alone would not see that.
  it 'reports no chart error in either container' do
    expect(page).to have_no_text('Error Loading Chart')
    expect(page).to have_no_text('No adapter found')
  end
end
