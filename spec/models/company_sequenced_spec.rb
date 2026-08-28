# frozen_string_literal: true

require 'rails_helper'

# CompanySequenced replaced the sequenceid gem, which was pinned to a feature
# branch of a third-party fork. The two behaviours it has to keep are the
# per-company numbering and to_param, since the controllers load these records
# with `find_by: :sequence_num` and every generated path uses it.
RSpec.describe CompanySequenced do
  let(:company) { create(:company) }
  let(:other)   { create(:company) }

  before { Company.current_company_id = company.id }

  # Each model reaches the concern the same way, so the cases are written once
  # and run against all three.
  { Benefit => :benefit, Payroll => :payroll, UsersBenefit => :users_benefit }.each do |model, factory|
    describe model.name do
      it 'numbers the first record in a company 1' do
        expect(create(factory, company: company).sequence_num).to eq(1)
      end

      it 'counts up for each record after it' do
        numbers = Array.new(3) { create(factory, company: company).sequence_num }

        expect(numbers).to eq([1, 2, 3])
      end

      it 'counts separately for each company' do
        first  = create(factory, company: company)
        second = as_tenant(other) { create(factory, company: other) }

        expect(first.sequence_num).to eq(1)
        expect(second.sequence_num).to eq(1)
      end

      it 'keeps one company records out of another company sequence' do
        2.times { create(factory, company: company) }
        third = as_tenant(other) { create(factory, company: other) }

        expect(third.sequence_num).to eq(1)
      end

      it 'uses the number as the URL identifier' do
        record = create(factory, company: company)

        expect(record.to_param).to eq(record.sequence_num.to_s)
      end

      it 'never assigns the same number twice within a company' do
        numbers = Array.new(4) { create(factory, company: company).sequence_num }

        expect(numbers.uniq.size).to eq(4)
      end
    end
  end

  # The gem read the newest row's number rather than the highest one. Those
  # agree only while numbers are handed out in id order, which stops being true
  # as soon as one is set explicitly.
  describe 'choosing the next number' do
    it 'counts from the highest number, not the most recently created row' do
      create(:benefit, company: company, sequence_num: 9)
      create(:benefit, company: company, sequence_num: 4)

      expect(create(:benefit, company: company).sequence_num).to eq(10)
    end

    it 'leaves an explicitly given number alone' do
      expect(create(:benefit, company: company, sequence_num: 42).sequence_num).to eq(42)
    end

    it 'does not reuse the number of a deleted record' do
      create(:benefit, company: company)
      second = create(:benefit, company: company)
      create(:benefit, company: company)
      second.destroy

      expect(create(:benefit, company: company).sequence_num).to eq(4)
    end
  end

  describe 'the unique index' do
    it 'refuses a duplicate number within one company' do
      create(:benefit, company: company, sequence_num: 1)

      expect { create(:benefit, company: company, sequence_num: 1) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'allows the same number in a different company' do
      create(:benefit, company: company, sequence_num: 1)
      duplicate = as_tenant(other) { create(:benefit, company: other, sequence_num: 1) }

      expect(duplicate.sequence_num).to eq(1)
    end
  end

  # Every one of these models carries a default scope keyed on the current
  # tenant, so counting through it would read nothing when no tenant is set and
  # hand out 1 forever. The concern counts unscoped for that reason.
  describe 'with no tenant set' do
    it 'still counts from the records already in the company' do
      2.times { create(:benefit, company: company) }
      Company.current_company_id = nil

      expect(create(:benefit, company: company).sequence_num).to eq(3)
    end
  end
end
