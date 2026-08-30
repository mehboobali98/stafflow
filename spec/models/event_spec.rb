# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event do
  let(:company) { create(:company, subdomain: 'acme') }

  describe 'tenancy' do
    # The default scope supplies company_id on create, which is the only reason
    # this model worked at all before it declared the association.
    it 'takes its company from the tenant scope when not given one' do
      event = as_tenant(company) do
        described_class.create!(name: 'Kickoff', starts_at: 1.week.from_now)
      end

      expect(event.company_id).to eq(company.id)
    end

    # Every other tenant-owned model declares this. Without it Event has no
    # `company` writer at all, so it can only be built by setting the id.
    it 'can be given its company directly, like every other tenant model' do
      event = as_tenant(company) do
        described_class.new(company: company, name: 'Kickoff', starts_at: 1.week.from_now)
      end

      expect(event.company).to eq(company)
      expect(event.company_id).to eq(company.id)
    end
  end

  describe '#validate_event_year' do
    subject(:event) { as_tenant(company) { build(:event) } }

    it 'accepts an ordinary date' do
      expect(as_tenant(company) { event.validate_event_year('2027-01-15') }).to be(true)
    end

    it 'rejects a year of more than four digits' do
      as_tenant(company) { expect(event.validate_event_year('12027-01-15')).to be(false) }

      expect(event.errors[:event_year]).to include(I18n.t('event.messages.error.event_year'))
    end

    # `rescue Type::Error` names a class that does not exist. Ruby only
    # evaluates a rescue clause when something is raised, and it evaluates them
    # in order - so this one raised NameError before the working Date::Error
    # clause below it could ever be reached.
    it 'reports a missing date rather than raising' do
      as_tenant(company) { expect(event.validate_event_year(nil)).to be(false) }

      expect(event.errors[:event_date]).to include(I18n.t('event.messages.error.nil_date_input'))
    end

    it 'reports an unparseable date rather than raising' do
      as_tenant(company) { expect(event.validate_event_year('not a date')).to be(false) }

      expect(event.errors[:event_date]).to include(I18n.t('event.messages.error.invalid_date'))
    end
  end

  describe 'validation on create' do
    it 'reports a missing start rather than comparing nil to a date' do
      event = as_tenant(company) { described_class.new(name: 'Kickoff') }

      expect(as_tenant(company) { event.valid?(:create) }).to be(false)
      expect(event.errors[:starts_at]).to be_present
    end

    it 'refuses an event in the past' do
      event = as_tenant(company) { described_class.new(name: 'Kickoff', starts_at: 1.week.ago) }

      as_tenant(company) { event.valid?(:create) }
      expect(event.errors[:event_date]).to include(I18n.t('event.messages.error.event_date'))
    end
  end
end
