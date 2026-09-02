# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'the list pages', type: :system do
  let!(:company) { create(:company, subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }
  let!(:owner) do
    as_tenant(company) { create(:user, :account_owner, company: company, email: 'owner@example.com') }
  end

  before { sign_in_as(company, owner) }

  describe 'the employee list' do
    let!(:engineering) { as_tenant(company) { create(:department, company: company, name: 'Engineering') } }
    let!(:support) { as_tenant(company) { create(:department, company: company, name: 'Support') } }

    before do
      as_tenant(company) do
        create(:user, :employee, company: company, department: engineering, email: 'ada@example.com')
        create(:user, :employee, company: company, department: support, email: 'grace@example.com')
      end
    end

    it 'replaces only the list, leaving the page around it alone' do
      visit_tenant(company, members_path)
      expect(page).to have_content('ada@example.com')
      expect(page).to have_content('grace@example.com')
      page.execute_script("document.querySelector('.sidebar').dataset.probe = 'kept'")

      select 'Engineering', from: 'department_id'

      expect(page).to have_no_content('grace@example.com')
      expect(page).to have_content('ada@example.com')
      expect(page.evaluate_script("document.querySelector('.sidebar').dataset.probe")).to eq 'kept'
    end

    it 'puts the filter in the address bar so the result can be linked to' do
      visit_tenant(company, members_path)

      select 'Engineering', from: 'department_id'
      expect(page).to have_no_content('grace@example.com')

      expect(page).to have_current_path(/department_id=#{engineering.id}/)
    end

    it 'keeps the filter in the form it was typed into' do
      visit_tenant(company, members_path)

      fill_in 'match_users_name', with: 'ada'

      expect(page).to have_no_content('grace@example.com')
      expect(page).to have_field('match_users_name', with: 'ada')
    end

    it 'clears the filter when reset' do
      visit_tenant(company, members_path)
      select 'Engineering', from: 'department_id'
      expect(page).to have_no_content('grace@example.com')

      click_on I18n.t('forms.buttons.reset_filters')

      expect(page).to have_content('grace@example.com')
      expect(page).to have_select('department_id', selected: I18n.t('forms.labels.department'))
    end
  end

  describe 'the leave list' do
    let!(:leaves) do
      as_tenant(company) do
        %w[Annual Sick Casual Maternity Paternity Bereavement].map do |name|
          create(:leave, company: company, name: name)
        end
      end
    end

    it 'shows only the first page' do
      visit_tenant(company, leaves_path)

      expect(page).to have_css('tbody tr', count: PAGE_SIZE)
    end

    it 'reaches the leave types past the first page' do
      visit_tenant(company, leaves_path)
      sixth = leaves.map(&:name).max
      expect(page).to have_no_content(sixth)

      click_on '2'

      expect(page).to have_content(sixth)
    end
  end

  describe 'the event list' do
    it 'renders its empty state rather than failing' do
      visit_tenant(company, events_path)

      expect(page).to have_content(I18n.t('event.no_events'))
    end

    it 'renders the table beside the calendar link, not inside it' do
      as_tenant(company) { create(:event, company: company, name: 'All hands', starts_at: 2.days.from_now) }
      visit_tenant(company, events_path)

      expect(page).to have_content('All hands')
      expect(page).to have_css('a', text: I18n.t('event.forms.links.view_calendar').strip)
      within('.page-shell') do
        expect(page).to have_css("a[href='#{display_calendar_events_path}']", count: 1)
      end
    end
  end
end
