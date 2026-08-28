# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payroll do
  let(:company)    { create(:company) }
  let(:department) { create(:department, company: company) }

  before do
    Company.current_company_id = company.id
    # Setting validates leave_resets_at on update by parsing it, and raises
    # Date::Error when it is nil - which is how Company#build_company_setting
    # leaves it. See spec/models/setting_spec.rb.
    setting.update_columns(leave_resets_at: Date.today.end_of_year)
  end

  # Read through the table rather than company.setting: the association is
  # cached from the before_save that builds it, so it does not reflect writes
  # made behind it.
  def setting
    Setting.unscoped.find_by!(company_id: company.id)
  end

  # Set the rate only after every user exists: saving a user saves the company,
  # and Company#before_save rebuilds the setting at DEFAULT_TAX_RATE.
  def set_tax_rate(rate)
    setting.update!(tax_rate: rate)
  end

  def employee(salary: 100_000.0, **attrs)
    create(:user, :employee, company: company, department: department,
                             base_salary: salary, **attrs)
  end

  describe '.generate_payroll' do
    context 'with no benefits assigned' do
      it 'applies the company tax rate to the base salary' do
        user = employee(salary: 100_000.0)
        set_tax_rate(10.0)
        payroll = described_class.generate_payroll(user.reload)

        expect(payroll.base_salary).to      eq(100_000.0)
        expect(payroll.salary_after_tax).to eq(90_000.0)
        expect(payroll.gross_salary).to     eq(90_000.0)
      end

      it 'honours a changed tax rate' do
        user = employee(salary: 80_000.0)
        set_tax_rate(25.0)
        payroll = described_class.generate_payroll(user.reload)

        expect(payroll.salary_after_tax).to eq(60_000.0)
      end

      it 'leaves the salary whole at a zero rate' do
        user = employee(salary: 50_000.0)
        set_tax_rate(0.001)
        payroll = described_class.generate_payroll(user.reload)

        expect(payroll.salary_after_tax).to be_within(1.0).of(50_000.0)
      end
    end

    context 'with benefits assigned' do
      it 'adds every assigned benefit on top of the after-tax salary' do
        user = employee(salary: 100_000.0)
        set_tax_rate(10.0)
        create(:users_benefit, company: company, user: user, amount: 15_000.0)
        create(:users_benefit, company: company, user: user, amount: 5_000.0)

        payroll = described_class.generate_payroll(user.reload)

        expect(payroll.salary_after_tax).to eq(90_000.0)
        expect(payroll.gross_salary).to     eq(110_000.0)
      end

      it 'itemises each benefit as an applied_benefit row' do
        user = employee
        create(:users_benefit, company: company, user: user, amount: 15_000.0)
        create(:users_benefit, company: company, user: user, amount: 2_500.0)

        payroll = described_class.generate_payroll(user.reload)

        expect(payroll.applied_benefits.count).to eq(2)
        expect(payroll.applied_benefits.pluck(:amount)).to contain_exactly(15_000.0, 2_500.0)
      end

      it 'records the benefit each line came from' do
        user    = employee
        benefit = create(:benefit, company: company, name: 'Transport')
        create(:users_benefit, company: company, user: user, benefit: benefit, amount: 5_000.0)

        payroll = described_class.generate_payroll(user.reload)

        expect(payroll.applied_benefits.first.benefit_id).to eq(benefit.id)
      end
    end

    it 'stamps the payroll with the employee tenant' do
      payroll = described_class.generate_payroll(employee)
      expect(payroll.company_id).to eq(company.id)
    end

    it 'persists the payroll' do
      expect { described_class.generate_payroll(employee) }
        .to change { described_class.count }.by(1)
    end
  end

  # Regression: deliver_payroll_generation_email called `.nil` rather than
  # `.nil?`, and dereferenced user.department unconditionally. Generating
  # payroll for anyone whose department had no head, or for an account owner
  # with no department at all, raised NoMethodError from an after_create hook.
  describe 'the department head notification' do
    it 'generates payroll when the department has no head' do
      user = employee

      expect { described_class.generate_payroll(user) }.not_to raise_error
    end

    it 'generates payroll for an account owner, who has no department' do
      owner = create(:user, :account_owner, company: company)
      owner.update_columns(base_salary: 200_000.0)

      expect { described_class.generate_payroll(owner.reload) }.not_to raise_error
    end

    it 'queues a notification when the department does have a head' do
      create(:user, :department_head, company: company, department: department)
      user = employee

      # Users are built outside the block because User#after_create queues a
      # password email of its own, which would be counted here.
      expect { described_class.generate_payroll(user) }
        .to change { Delayed::Job.count }.by(1)
    end

    it 'queues nothing when there is no head to notify' do
      user = employee

      expect { described_class.generate_payroll(user) }
        .not_to change { Delayed::Job.count }
    end
  end

  describe '.payroll_already_generated?' do
    it 'is false for an employee with no payroll yet' do
      expect(described_class.payroll_already_generated?(employee)).to be(false)
    end

    it 'is true once payroll exists for the current month' do
      user = employee
      described_class.generate_payroll(user)

      expect(described_class.payroll_already_generated?(user.reload)).to be(true)
    end

    it 'is false again for payroll generated in an earlier month' do
      user    = employee
      payroll = described_class.generate_payroll(user)
      payroll.update_columns(created_at: 2.months.ago)

      expect(described_class.payroll_already_generated?(user.reload)).to be(false)
    end
  end
end
