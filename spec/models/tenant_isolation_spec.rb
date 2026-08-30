# frozen_string_literal: true

require 'rails_helper'

# The application is multi-tenant by default scope rather than by discipline:
# ApplicationRecord.inherited gives every subclass
#
#   default_scope { multitenant? ? where(company_id: ...) : all }
#
# evaluated per query, so a model opting out with set_not_multitenant is read
# correctly wherever in the body the call sits. These specs exist to fail loudly
# if that mechanism is ever weakened, because nothing else in the code would
# notice — queries would simply start returning other companies' rows.
RSpec.describe 'tenant isolation' do
  let(:acme)   { create(:company, name: 'Acme',   subdomain: 'acme') }
  let(:globex) { create(:company, name: 'Globex', subdomain: 'globex') }

  # Every model that owns a company_id column and does not opt out.
  TENANT_MODELS = [Department, Designation, Leave, Benefit, User, UserLeave,
                   UsersBenefit, Payroll, Event, Notification, Setting,
                   AppliedLeave, AppliedBenefit].freeze

  describe 'the scoping mechanism itself' do
    it 'marks every company-owned model as multitenant' do
      TENANT_MODELS.each do |model|
        expect(model).to be_multitenant, "#{model} is not tenant scoped"
      end
    end

    it 'exempts Company, which is the tenant and cannot be scoped to itself' do
      expect(Company).not_to be_multitenant
    end

    it 'injects a company_id condition into every tenant model query' do
      as_tenant(acme) do
        TENANT_MODELS.each do |model|
          expect(model.all.to_sql).to include('company_id'),
                                      "#{model} query carries no company_id condition"
        end
      end
    end

    def enabled_tracepoints
      ObjectSpace.each_object(TracePoint).count(&:enabled?)
    end

    # There is nothing else to assert this against: a hook left enabled changes
    # no query and raises nothing, it just accumulates. The scoping mechanism
    # has no business installing process-wide hooks at all, so the count simply
    # must not move.
    it 'installs no process-wide hook when a model is defined' do
      expect { Class.new(ApplicationRecord) { self.table_name = 'departments' } }
        .not_to(change { enabled_tracepoints })
    end

    it 'installs no process-wide hook when a model opts out either' do
      expect do
        Class.new(ApplicationRecord) do
          self.table_name = 'companies'
          set_not_multitenant
        end
      end.not_to(change { enabled_tracepoints })
    end

    # The property the whole mechanism turns on: `inherited` runs before the
    # class body, so the opt-out cannot be read when the scope is installed.
    # Deciding it per query gives the same answer wherever the call sits.
    it 'honours set_not_multitenant declared at the end of a class body' do
      model = Class.new(ApplicationRecord) do
        self.table_name = 'companies'
        def self.something_else = nil
        set_not_multitenant
      end

      expect(model).not_to be_multitenant
      expect(model.all.to_sql).not_to include('company_id')
    end

    it 'scopes a model that never opts out, wherever its body ends' do
      model = Class.new(ApplicationRecord) { self.table_name = 'departments' }

      as_tenant(acme) { expect(model.all.to_sql).to include('company_id') }
    end
  end

  describe 'reading across tenants' do
    before do
      as_tenant(acme)   { create(:department, company: acme,   name: 'Acme Engineering') }
      as_tenant(globex) { create(:department, company: globex, name: 'Globex Engineering') }
    end

    it 'returns only the current tenant rows' do
      as_tenant(acme) do
        expect(Department.pluck(:name)).to contain_exactly('Acme Engineering')
      end

      as_tenant(globex) do
        expect(Department.pluck(:name)).to contain_exactly('Globex Engineering')
      end
    end

    it 'has both rows in the table regardless' do
      expect(unscoped(Department).pluck(:name))
        .to contain_exactly('Acme Engineering', 'Globex Engineering')
    end

    it 'cannot fetch another tenant record by id' do
      other = as_tenant(globex) { Department.first }

      as_tenant(acme) do
        expect { Department.find(other.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect(Department.find_by(id: other.id)).to be_nil
      end
    end

    it 'excludes other tenants from counts and aggregates' do
      as_tenant(acme) do
        expect(Department.count).to eq(1)
        expect(Department.exists?).to be(true)
      end
      expect(unscoped(Department).count).to eq(2)
    end
  end

  describe 'writing' do
    it 'stamps new records with the current tenant without being told' do
      as_tenant(acme) do
        leave = Leave.create!(name: 'Annual', default_count: 20.0)
        expect(leave.company_id).to eq(acme.id)
      end
    end

    it 'does not let one tenant destroy another tenant rows' do
      globex_dept = as_tenant(globex) { create(:department, company: globex) }

      as_tenant(acme) { Department.destroy_all }

      expect(unscoped(Department).exists?(globex_dept.id)).to be(true)
    end
  end

  describe 'when no tenant is set' do
    before { as_tenant(acme) { create(:department, company: acme) } }

    it 'returns nothing rather than everything' do
      Company.current_company_id = nil
      expect(Department.count).to eq(0)
    end
  end

  describe 'tenant context lifecycle' do
    it 'is restored after the block exits' do
      as_tenant(acme) do
        expect(Company.current_company_id).to eq(acme.id)
        as_tenant(globex) { expect(Company.current_company_id).to eq(globex.id) }
        expect(Company.current_company_id).to eq(acme.id)
      end
    end

    it 'is stored per thread, so concurrent requests cannot see each other' do
      Company.current_company_id = acme.id

      other_thread_value = Thread.new { Company.current_company_id }.value

      expect(other_thread_value).to be_nil
      expect(Company.current_company_id).to eq(acme.id)
    end
  end
end
