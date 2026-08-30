# frozen_string_literal: true

require 'rails_helper'

# `t.float` on MySQL is FLOAT(24) - single precision, roughly seven significant
# decimal digits. Salaries need more than that, and the column silently spent
# the difference: every figure below came back wrong before these columns were
# decimal, and nothing in the app or the suite was looking.
RSpec.describe 'decimal money columns' do
  let(:company)    { create(:company) }
  let(:department) { as_tenant(company) { create(:department, company: company) } }

  # Read through the table rather than company.setting: the association is
  # cached from the before_create that builds it, so it does not reflect writes
  # made behind it.
  def setting
    Setting.unscoped.find_by!(company_id: company.id)
  end

  describe 'a salary with cents' do
    # Left of the arrow is what a FLOAT(24) answered with.
    {
      '100000.10' => '100000.0',
      '1234567.89' => '1234570.0',
      '49999.99' => '50000.0'
    }.each do |amount, was|
      it "stores #{amount}, which used to read back as #{was}" do
        user = as_tenant(company) do
          create(:user, :employee, company: company, department: department,
                                   base_salary: BigDecimal(amount))
        end

        expect(user.reload.base_salary).to eq(BigDecimal(amount))
      end
    end
  end

  describe 'a generated payroll' do
    let(:user) do
      as_tenant(company) do
        create(:user, :employee, company: company, department: department,
                                 base_salary: BigDecimal('100000.10'))
      end
    end

    before do
      as_tenant(company) do
        setting.update!(tax_rate: 10)
        benefit = create(:benefit, company: company)
        ['15000.33', '5000.77', '1250.05'].each do |amount|
          create(:users_benefit, company: company, user: user, benefit: benefit,
                                 amount: BigDecimal(amount))
        end
      end
    end

    # 10% of 100000.10 is 10000.01, leaving 90000.09, and the benefits total
    # 21251.15. Every step lands on a whole cent, so nothing here is rounding:
    # the float column returned 87500.0 and 108751.0 for the last two, which is
    # $87.74 missing from a payslip rather than a rounding artefact.
    it 'carries the cents through tax and benefits' do
      payroll = as_tenant(company) { Payroll.generate_payroll(user) }.reload

      expect(payroll.base_salary).to      eq(BigDecimal('100000.10'))
      expect(payroll.salary_after_tax).to eq(BigDecimal('90000.09'))
      expect(payroll.gross_salary).to     eq(BigDecimal('111251.24'))
    end

    it 'sums the benefits exactly' do
      total = as_tenant(company) { user.users_benefits.sum(:amount) }

      expect(total).to eq(BigDecimal('21251.15'))
    end
  end

  # The guard for the whole change. Leave counts were never the demonstrated
  # problem - three significant digits sit well inside what a float holds - but
  # they are counted and compared for equality, so they moved with the rest.
  it 'leaves no money or leave-day column in the float type' do
    columns = {
      AppliedBenefit => %i[amount],
      Benefit => %i[default_amount],
      Leave => %i[default_count],
      Payroll => %i[base_salary gross_salary salary_after_tax],
      Setting => %i[tax_rate],
      User => %i[base_salary],
      UserLeave => %i[total_count remaining_count],
      UsersBenefit => %i[amount]
    }

    types = columns.flat_map do |model, attributes|
      attributes.map { |attribute| ["#{model.table_name}.#{attribute}", model.columns_hash[attribute.to_s].type] }
    end

    expect(types.reject { |_name, type| type == :decimal }).to be_empty
  end
end
