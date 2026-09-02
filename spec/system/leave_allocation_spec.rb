# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'the leave allocation modal', type: :system do
  let!(:company) { create(:company, subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }
  let!(:hr) do
    as_tenant(company) do
      create(:user, :hr, company: company, department: department, email: 'hr@example.com')
    end
  end
  let!(:user_leave) do
    as_tenant(company) do
      create(:user_leave, company: company, user: hr,
                          leave: create(:leave, company: company, name: 'Annual'),
                          total_count: 20.0, remaining_count: 20.0)
    end
  end

  before do
    sign_in_as(company, hr)
    visit_tenant(company, member_user_leaves_path(hr))
  end

  it 'opens on the row it was asked for' do
    expect(page).to have_no_css('.modal.show')

    find("a[href='#{edit_member_user_leave_path(hr, user_leave)}']").click

    expect(page).to have_css('.modal.show')
    expect(page).to have_field('user_leave_total_count', with: '20.0')
  end

  it 'shows the new count in the table and closes' do
    find("a[href='#{edit_member_user_leave_path(hr, user_leave)}']").click
    expect(page).to have_css('.modal.show')

    fill_in 'user_leave_total_count', with: '15'
    within('.modal.show') { find('input[type=submit]').click }

    expect(page).to have_no_css('.modal.show')
    expect(page).to have_css('td', exact_text: '15.0')
    expect(user_leave.reload.total_count).to eq 15
  end

  it 'closes without saving when dismissed' do
    find("a[href='#{edit_member_user_leave_path(hr, user_leave)}']").click
    expect(page).to have_css('.modal.show')

    within('.modal.show') { click_on I18n.t('user_leave.headings.close') }

    expect(page).to have_no_css('.modal.show')
    expect(page).to have_no_css('.modal-backdrop')
    expect(user_leave.reload.total_count).to eq 20
  end

  it 'keeps the modal open with its errors when the count is rejected' do
    find("a[href='#{edit_member_user_leave_path(hr, user_leave)}']").click
    expect(page).to have_css('.modal.show')

    fill_in 'user_leave_total_count', with: MAX_LEAVE_COUNT
    within('.modal.show') { find('input[type=submit]').click }

    expect(page).to have_css('.modal.show')
    expect(page).to have_css('#modal_flash_message .flash-message')
    expect(user_leave.reload.total_count).to eq 20
  end
end
