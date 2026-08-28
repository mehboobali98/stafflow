# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

# Permissions are spread across twelve concerns in app/models/concerns, which
# makes them easy to change one at a time and hard to see as a whole. This spec
# is the whole picture: a table per resource, one row per role.
RSpec.describe Ability do
  let(:company) { create(:company) }
  let(:other_company) { create(:company) }
  let(:department) { create(:department, company: company) }

  # In production an around_action holds the tenant for the whole request.
  # CanCan evaluates block conditions lazily, at the point of the ability
  # check, so the tenant has to be set for the whole example rather than only
  # while records are built - otherwise those blocks query a nil tenant and
  # silently find nothing.
  before { Company.current_company_id = company.id }

  def user_with(role, **attrs)
    create(:user, role, company: company, **attrs)
  end

  let(:owner)     { user_with(:account_owner) }
  let(:hr)        { user_with(:hr, department: department) }
  let(:head)      { user_with(:department_head, department: department) }
  let(:employee)  { user_with(:employee, department: department) }

  def ability_for(user)
    Ability.new(user)
  end

  describe 'an unauthenticated visitor' do
    it 'can do nothing at all' do
      ability = Ability.new(nil)
      [User, Leave, Benefit, Department, Payroll, Setting].each do |resource|
        expect(ability).not_to be_able_to(:read, resource.new)
      end
    end
  end

  describe 'Leave' do
    let(:leave) { create(:leave, company: company) }

    it 'is managed by the account owner and HR, read-only for everyone else' do
      expect(ability_for(owner)).to     be_able_to(:manage, leave)
      expect(ability_for(hr)).to        be_able_to(:manage, leave)

      expect(ability_for(head)).to      be_able_to(:read, leave)
      expect(ability_for(head)).not_to  be_able_to(:update, leave)
      expect(ability_for(employee)).to  be_able_to(:read, leave)
      expect(ability_for(employee)).not_to be_able_to(:create, leave)
    end

    it 'cannot be destroyed once it has balances assigned to people' do
      create(:user_leave, company: company, leave: leave, user: employee)

      expect(ability_for(owner)).not_to be_able_to(:destroy, leave.reload)
    end
  end

  describe 'Benefit' do
    let(:benefit) { create(:benefit, company: company) }

    it 'is managed by the account owner and HR, read-only for everyone else' do
      expect(ability_for(owner)).to        be_able_to(:manage, benefit)
      expect(ability_for(hr)).to           be_able_to(:manage, benefit)
      expect(ability_for(head)).to         be_able_to(:read, benefit)
      expect(ability_for(head)).not_to     be_able_to(:update, benefit)
      expect(ability_for(employee)).not_to be_able_to(:update, benefit)
    end
  end

  describe 'Department' do
    it 'lets a department head update only their own department' do
      other_department = create(:department, company: company)

      expect(ability_for(head)).to     be_able_to(:update, department)
      expect(ability_for(head)).not_to be_able_to(:update, other_department)
      expect(ability_for(head)).not_to be_able_to(:destroy, department)
    end

    it 'is read-only for employees' do
      expect(ability_for(employee)).to     be_able_to(:read, department)
      expect(ability_for(employee)).not_to be_able_to(:update, department)
    end
  end

  describe 'Setting' do
    let(:setting) { company.setting }

    it 'is editable by the account owner and HR only, and never created or destroyed' do
      expect(ability_for(owner)).to        be_able_to(:update, setting)
      expect(ability_for(hr)).to           be_able_to(:update, setting)
      expect(ability_for(owner)).not_to    be_able_to(:destroy, setting)
      expect(ability_for(owner)).not_to    be_able_to(:create, Setting.new(company_id: company.id))

      expect(ability_for(head)).not_to     be_able_to(:read, setting)
      expect(ability_for(employee)).not_to be_able_to(:read, setting)
    end
  end

  describe 'Payroll' do
    it 'is visible to an employee only for themselves' do
      own   = create(:payroll, company: company, user: employee)
      other = create(:payroll, company: company, user: hr)

      expect(ability_for(employee)).to     be_able_to(:read, own)
      expect(ability_for(employee)).not_to be_able_to(:read, other)
      expect(ability_for(employee)).not_to be_able_to(:create, own)
    end

    it 'is visible to a department head across their own department' do
      report  = user_with(:employee, department: department)
      payroll = create(:payroll, company: company, user: report)

      expect(ability_for(head)).to be_able_to(:read, payroll)
    end

    it 'can be created by the account owner and HR' do
      payroll = create(:payroll, company: company, user: employee)

      expect(ability_for(owner)).to be_able_to(:create, payroll)
      expect(ability_for(hr)).to    be_able_to(:create, payroll)
    end
  end

  describe 'User' do
    it 'stops anyone from editing their own salary, role or department' do
      [owner, hr, head, employee].each do |actor|
        User::SENSITIVE_ATTRIBUTES.each do |attribute|
          expect(ability_for(actor)).not_to be_able_to(:update, actor, attribute),
                                            "#{actor.role_name} can edit their own #{attribute}"
        end
      end
    end

    it 'stops the account owner from deleting themselves' do
      expect(ability_for(owner)).not_to be_able_to(:destroy, owner)
      expect(ability_for(owner)).to     be_able_to(:destroy, employee)
    end

    it 'stops HR from touching the account owner' do
      expect(ability_for(hr)).not_to be_able_to(:update, owner)
      expect(ability_for(hr)).not_to be_able_to(:destroy, owner)
      expect(ability_for(hr)).to     be_able_to(:update, employee)
    end

    it 'lets an employee edit only themselves' do
      colleague = user_with(:employee, department: department)

      expect(ability_for(employee)).to     be_able_to(:update, employee)
      expect(ability_for(employee)).not_to be_able_to(:update, colleague)
      expect(ability_for(employee)).not_to be_able_to(:destroy, colleague)
    end

    it 'confines a department head to their own department for edits' do
      own_report = user_with(:employee, department: department)
      elsewhere  = user_with(:employee, department: create(:department, company: company))

      expect(ability_for(head)).to     be_able_to(:update, own_report)
      expect(ability_for(head)).not_to be_able_to(:update, elsewhere)
    end

    it 'never grants anything on another company records' do
      outsider = as_tenant(other_company) { create(:user, :employee, company: other_company) }

      [owner, hr, head, employee].each do |actor|
        expect(ability_for(actor)).not_to be_able_to(:update, outsider)
        expect(ability_for(actor)).not_to be_able_to(:destroy, outsider)
      end
    end
  end
end
