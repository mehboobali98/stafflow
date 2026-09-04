# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'the HR leave queue', type: :system do
  let!(:company) { create(:company, subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }
  let!(:hr) do
    as_tenant(company) do
      create(:user, :hr, company: company, department: department, email: 'hr@example.com')
    end
  end
  let!(:applied_leave) { as_tenant(company) { create(:applied_leave, company: company) } }

  before do
    sign_in_as(company, hr)
    visit_tenant(company, all_applied_leaves_path)
  end

  it 'lists the request company-wide' do
    expect(page).to have_css('td', text: applied_leave.user.email)
  end

  # The cell interpolates leave_duration_name into an I18n key, and I18n answers
  # a bare key with the whole subtree behind it rather than a missing-translation
  # error - so an unvalidated duration type printed the entire labels hash here.
  # exact_text is what separates the two: the hash contains the label without
  # being equal to it.
  it 'renders the duration as its label rather than the subtree behind it' do
    expect(page).to have_css('td', exact_text: I18n.t('applied_leave.labels.full_day'))
  end

  # A key the view interpolates its way to and misses does not raise here: the
  # helper renders a span holding the humanised last segment, which reads close
  # enough to the real label to survive a look. Both cells above did.
  it 'resolves every key it renders' do
    expect(page).to have_no_css('.translation_missing')
  end

  describe 'approving in bulk' do
    it 'leaves the buttons disabled until something is selected' do
      expect(page).to have_css('#approve_leaves_btn[disabled]')
      expect(page).to have_css('#reject_leaves_btn[disabled]')

      check "applied_leave_#{applied_leave.id}"

      expect(page).to have_no_css('#approve_leaves_btn[disabled]')
      expect(page).to have_no_css('#reject_leaves_btn[disabled]')
    end

    it 'approves the selected requests and says how many' do
      check "applied_leave_#{applied_leave.id}"

      click_on I18n.t('applied_leave.links.approve_leaves')

      expect(page).to have_css('.flash-message',
                               text: I18n.t('applied_leave.messages.mass_approve', total: 1, actual: 1))
      expect(applied_leave.reload.state).to eq 'accepted'
    end

    it 'shows the new state in the table without reloading the page around it' do
      page.execute_script("document.querySelector('.sidebar').dataset.probe = 'kept'")
      check "applied_leave_#{applied_leave.id}"

      click_on I18n.t('applied_leave.links.reject_leaves')

      expect(page).to have_css('td', text: I18n.t('applied_leave.labels.rejected'))
      expect(page.evaluate_script("document.querySelector('.sidebar').dataset.probe")).to eq 'kept'
    end
  end

  describe 'filtering' do
    it 'narrows the queue without disturbing the page around it' do
      page.execute_script("document.querySelector('.sidebar').dataset.probe = 'kept'")
      expect(page).to have_content(applied_leave.user.email)

      select I18n.t('applied_leave.labels.accepted'), from: 'filter'

      expect(page).to have_no_content(applied_leave.user.email)
      expect(page.evaluate_script("document.querySelector('.sidebar').dataset.probe")).to eq 'kept'
    end
  end
end
