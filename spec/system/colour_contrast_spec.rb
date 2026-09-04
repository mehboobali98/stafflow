# frozen_string_literal: true

require 'rails_helper'

# The one part of "does this look right" that is measurable rather than a
# matter of taste, and the only automated check phase 7 has against appearance.
# It exists because the hero subtitle shipped at 2.81:1 - rgba(255,255,255,.6)
# on the brand blue, under the 3:1 that 24px text needs - and nothing in a
# behaviour suite can see that.
RSpec.describe 'colour contrast', type: :system do
  let!(:company) { create(:company, name: 'Acme Corporation', subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }
  let!(:hr) do
    as_tenant(company) do
      create(:user, :hr, company: company, department: department, email: 'hr@example.com')
    end
  end

  def expect_readable(selectors)
    styles = computed_styles(selectors)

    failures = styles.compact.filter_map do |style|
      ratio = contrast_ratio(style['color'], style['background'])
      needed = required_ratio(style)
      next if ratio >= needed

      "#{style['selector']} is #{ratio}:1, needs #{needed}:1"
    end

    expect(failures).to be_empty
  end

  # A selector that matches nothing passes silently, so the list is checked
  # against the page before it is trusted.
  def expect_all_present(selectors)
    missing = computed_styles(selectors).each_with_index
                                        .filter_map { |style, i| selectors[i] if style.nil? }

    expect(missing).to be_empty
  end

  describe 'the landing page' do
    let(:selectors) do
      ['#hero h1', '#hero h2', '.section-title h2', '.section-title p',
       '#header .logo a', '.nav-link']
    end

    before { visit_apex '/' }

    it 'has every selector it claims to check' do
      expect_all_present(selectors)
    end

    it 'clears AA on the text over the hero and the sections' do
      expect_readable(selectors)
    end
  end

  describe 'the signed-in chrome' do
    let(:selectors) do
      ['.navbar-brand', '.sidebar a', 'body', '.table-head th', '.breadcrumbs',
       '[data-component=badge]', '[data-component=button]',
       '[data-component=page-header] .page-header__links a']
    end

    before do
      as_tenant(company) { create(:applied_leave, company: company) }
      sign_in_as(company, hr)
      visit_tenant(company, all_applied_leaves_path)
    end

    it 'has every selector it claims to check' do
      expect_all_present(selectors)
    end

    it 'clears AA on the navbar, sidebar, body and table headings' do
      expect_readable(selectors)
    end
  end

  # The combobox is the one control that paints text on the accent rather than
  # on a surface, and the highlight only exists while the list is open.
  describe 'the combobox dropdown' do
    let(:selectors) { ['.combobox__input', '.combobox__option', '.combobox__option.is-active'] }

    before do
      as_tenant(company) do
        create(:user, :employee, company: company, department: department,
                                 email: 'employee@example.com')
      end
      sign_in_as(company, hr)
      visit_tenant(company, new_applied_leave_by_hr_applied_leaves_path)
      find_by_id('applied_leave_member_id_search').send_keys('employee')
      find('[role=option]')
      find_by_id('applied_leave_member_id_search').send_keys(:down)
      find('.combobox__option.is-active')
    end

    it 'has every selector it claims to check' do
      expect_all_present(selectors)
    end

    it 'clears AA on the search field and on both option states' do
      expect_readable(selectors)
    end
  end
end
