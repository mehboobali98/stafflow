# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  let(:company)    { create(:company) }
  let(:department) { create(:department, company: company) }
  # build(:user) builds its associations rather than creating them, which
  # leaves designation_id nil and fails the presence validation, so specs that
  # use build pass a persisted designation explicitly.
  let(:designation) { create(:designation, company: company, department: department) }

  before { Company.current_company_id = company.id }

  describe 'required fields' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:date_of_birth) }
    it { is_expected.to validate_presence_of(:role_id) }
    it { is_expected.to validate_presence_of(:email) }
  end

  describe 'email' do
    it 'is unique within a company' do
      create(:user, :employee, company: company, department: department, email: 'taken@example.com')
      duplicate = build(:user, :employee, company: company, department: department, email: 'taken@example.com')

      expect(duplicate).not_to be_valid
    end

    it 'may be reused in a different company' do
      other = create(:company)
      create(:user, :employee, company: company, department: department, email: 'shared@example.com')

      reused = as_tenant(other) do
        other_department  = create(:department, company: other)
        other_designation = create(:designation, company: other, department: other_department)
        build(:user, :employee, company: other, email: 'shared@example.com',
                                department: other_department, designation: other_designation)
      end

      expect(reused).to be_valid
    end
  end

  describe 'department and designation' do
    it 'rejects a designation belonging to a different department' do
      other_department = create(:department, company: company)
      mismatched = create(:designation, company: company, department: other_department)

      user = build(:user, :employee, company: company,
                                     department: department, designation: mismatched)

      expect(user).not_to be_valid
    end

    it 'is required for an employee' do
      user = build(:user, :employee, company: company, department: nil, designation: nil)
      expect(user).not_to be_valid
    end

    it 'is not required for the account owner' do
      expect(build(:user, :account_owner, company: company)).to be_valid
    end
  end

  describe 'base salary' do
    it 'must be greater than zero' do
      user = build(:user, :employee, company: company, department: department,
                                     designation: designation, base_salary: 0)
      expect(user).not_to be_valid
    end

    it 'is not required for the account owner' do
      expect(build(:user, :account_owner, company: company, base_salary: nil)).to be_valid
    end
  end

  describe 'gender' do
    it 'accepts the listed values' do
      User::GENDERS.each_value do |value|
        user = build(:user, :employee, company: company, department: department,
                                       designation: designation, gender: value)
        expect(user).to be_valid, "#{value} was rejected"
      end
    end

    it 'rejects anything else' do
      user = build(:user, :employee, company: company, department: department,
                                     designation: designation, gender: 'Other')
      expect(user).not_to be_valid
    end
  end

  describe 'roles' do
    it 'reports each role by name' do
      User::ROLES.each_key do |role|
        user = build(:user, role, company: company)
        expect(user.role_name).to eq(role)
      end
    end

    it 'answers the role predicates' do
      expect(build(:user, :hr, company: company, designation: designation)).to be_hr
      expect(build(:user, :employee, company: company, designation: designation)).to be_employee
      expect(build(:user, :account_owner, company: company)).to be_account_owner
      expect(build(:user, :department_head, company: company, designation: designation)).to be_department_head
    end

    it 'refuses to promote anyone to account owner through role_id_valid?' do
      user = build(:user, :employee, company: company, designation: designation)
      expect(user.role_id_valid?(User::ROLES[:account_owner])).to be(false)
    end
  end

  describe '#full_name' do
    it 'joins first and last name' do
      user = build(:user, :employee, company: company, designation: designation,
                                     first_name: 'Grace', last_name: 'Hopper')
      expect(user.full_name).to eq('Grace Hopper')
    end
  end

  describe '#date_of_birth_valid?' do
    subject(:user) { build(:user, :employee, company: company, designation: designation) }

    it 'accepts a past date' do
      expect(user.date_of_birth_valid?(Date.new(1990, 5, 1))).to be(true)
    end

    it 'rejects a future date' do
      expect(user.date_of_birth_valid?(Date.today + 1)).to be(false)
    end

    it 'rejects an unparseable date instead of raising' do
      expect(user.date_of_birth_valid?('not a date')).to be(false)
    end
  end

  describe '#get_available_leaves' do
    it 'lists only balances with days remaining' do
      user      = create(:user, :employee, company: company, department: department)
      available = create(:leave, company: company)
      spent     = create(:leave, company: company)

      create(:user_leave, company: company, user: user, leave: available, remaining_count: 5.0)
      create(:user_leave, company: company, user: user, leave: spent, remaining_count: 0.0)

      expect(user.get_available_leaves.map(&:name)).to contain_exactly(available.name)
    end
  end

  # remaining_count used to validate greater_than: MIN_LEAVE_COUNT, which is 0,
  # so an employee who used their entire allowance could not have that balance
  # saved and approving their last day of leave failed validation.
  describe 'exhausting a leave balance' do
    it 'can be saved when the balance reaches zero' do
      user  = create(:user, :employee, company: company, department: department)
      leave = create(:leave, company: company)
      balance = create(:user_leave, company: company, user: user, leave: leave, remaining_count: 1.0)

      expect(balance.update(remaining_count: 0.0)).to be(true)
    end
  end

  describe 'account creation' do
    it 'queues a password email' do
      expect { create(:user, :employee, company: company, department: department) }
        .to change { Delayed::Job.count }.by(1)
    end
  end
end
