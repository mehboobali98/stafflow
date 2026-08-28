# frozen_string_literal: true

require 'rails_helper'

# A factory that silently produces an invalid record makes every other spec
# lie, so each one is exercised directly.
RSpec.describe 'factories' do
  it 'builds a valid company' do
    expect(create(:company)).to be_valid
  end

  context 'within a tenant' do
    let(:company) { create(:company) }

    %i[department designation event leave user_leave benefit users_benefit].each do |factory_name|
      it "builds a valid #{factory_name}" do
        as_tenant(company) do
          record = create(factory_name, company: company)
          expect(record).to be_valid
          expect(record.company_id).to eq(company.id)
        end
      end
    end

    %i[employee hr department_head account_owner].each do |role|
      it "builds a valid #{role} user" do
        as_tenant(company) do
          user = create(:user, role, company: company)
          expect(user).to be_valid
          expect(user.role_id).to eq(User::ROLES[role])
        end
      end
    end

    it 'builds a valid applied_leave' do
      as_tenant(company) do
        expect(create(:applied_leave, company: company)).to be_valid
      end
    end
  end
end
