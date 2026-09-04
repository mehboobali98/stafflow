# frozen_string_literal: true

require 'rails_helper'

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

  # Methods rather than `let`, because a memoized Capybara node goes stale the
  # moment the page it was found on is replaced.
  def search
    find_by_id('applied_leave_member_id_search')
  end

  def listbox
    find_by_id('applied_leave_member_id_search_listbox', visible: :all)
  end

  def member_field
    find_by_id('applied_leave_member_id', visible: :all)
  end

  def search_for_the_employee
    search.send_keys('employee')
    expect(page).to have_css('[role=option]', text: employee.email)
  end

  before do
    sign_in_as(company, hr)
    visit_tenant(company, new_applied_leave_by_hr_applied_leaves_path)
  end

  it 'renders the member picker as a combobox over a hidden field' do
    expect(page).to have_css('[data-component=combobox]')
    expect(search[:role]).to eq('combobox')
    expect(search['aria-expanded']).to eq('false')
    expect(search['aria-controls']).to eq(listbox[:id])
    expect(listbox).not_to be_visible
    expect(member_field.value).to be_blank
  end

  it 'searches employees and offers what came back' do
    search_for_the_employee

    expect(listbox).to be_visible
    expect(search['aria-expanded']).to eq('true')
  end

  it 'fills the leave types from the employee picked with the mouse' do
    search_for_the_employee
    find('[role=option]', text: employee.email).click

    expect(page).to have_css('#leaves_select option', text: 'Annual')
    expect(member_field.value).to eq(employee.id.to_s)
  end

  # The whole reason this control is hand-written rather than inherited: select2
  # shipped keyboard support and this has to earn it.
  it 'fills the leave types from an employee picked with the keyboard alone' do
    search_for_the_employee
    search.send_keys(:down)

    expect(search['aria-activedescendant']).to eq(find('[role=option]', text: employee.email)[:id])

    search.send_keys(:enter)

    expect(page).to have_css('#leaves_select option', text: 'Annual')
    expect(member_field.value).to eq(employee.id.to_s)
    expect(search.value).to eq(employee.email)
  end

  it 'marks the active option selected and leaves the others alone' do
    search_for_the_employee
    search.send_keys(:down)

    expect(page).to have_css('[role=option][aria-selected=true]', count: 1)
    expect(page).to have_css('[role=option][aria-selected=true]', text: employee.email)
  end

  it 'closes on escape without picking anything' do
    search_for_the_employee
    search.send_keys(:escape)

    expect(listbox).not_to be_visible
    expect(search['aria-expanded']).to eq('false')
    expect(search['aria-activedescendant']).to be_nil
    expect(member_field.value).to be_blank
  end

  # Editing the text after a pick has to invalidate the id, or the form submits
  # a member the field no longer names.
  it 'drops the chosen member when the search text is edited' do
    search_for_the_employee
    find('[role=option]', text: employee.email).click
    expect(member_field.value).to eq(employee.id.to_s)

    search.send_keys(:backspace)

    expect(member_field.value).to be_blank
  end

  it 'announces the result count to a screen reader' do
    search_for_the_employee

    expect(page).to have_css('#applied_leave_member_id_search_status', visible: :all,
                                                                       text: '1 matches')
  end

  it 'leaves no label pointing at an id that does not exist' do
    expect(orphaned_labels).to be_empty
  end
end
