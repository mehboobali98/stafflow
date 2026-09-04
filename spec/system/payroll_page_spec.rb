# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'the payroll page', type: :system do
  let!(:company) { create(:company, subdomain: 'acme') }
  let(:department) { as_tenant(company) { create(:department, company: company) } }
  let!(:hr) do
    as_tenant(company) do
      create(:user, :hr, company: company, department: department, email: 'hr@example.com')
    end
  end

  let!(:payroll) do
    as_tenant(company) do
      Setting.unscoped.find_by!(company_id: company.id).update!(tax_rate: 10)
      employee = create(:user, :employee, company: company, department: department,
                                          base_salary: BigDecimal('100000.10'))
      benefit = create(:benefit, company: company)
      create(:users_benefit, company: company, user: employee, benefit: benefit,
                             amount: BigDecimal('15000.33'))
      Payroll.generate_payroll(employee)
    end
  end

  before do
    sign_in_as(company, hr)
    visit_tenant(company, member_payroll_path(payroll.user, payroll))
  end

  # The last assertion the migration needs: the cents survive the column, the
  # calculation and the page. The base salary alone used to arrive here as
  # Rs. 100,000.00 - FLOAT(24) could not hold the ten cents - and every figure
  # derived from it inherited the loss.
  it 'prints every figure to the cent' do
    expect(page).to have_css('td', text: 'Rs. 100,000.10')
    expect(page).to have_css('td', text: 'Rs. 90,000.09')
    expect(page).to have_css('td', text: 'Rs. 105,000.42')
  end
end
