# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppliedLeave do
  let(:company)    { create(:company) }
  let(:department) { create(:department, company: company) }

  before { Company.current_company_id = company.id }

  let(:employee) { create(:user, :employee, company: company, department: department) }
  let(:leave)    { create(:leave, company: company, default_count: 20.0) }
  let(:balance) do
    create(:user_leave, company: company, user: employee, leave: leave,
                        total_count: 20.0, remaining_count: 20.0)
  end

  # Only weekdays count toward a leave, so windows are pinned to a Monday.
  def next_monday
    date = Date.today + 1
    date += 1 until date.wday == 1
    date
  end

  def apply(from: next_monday, till: nil, duration: :full_day)
    create(:applied_leave, company: company, user_leave: balance,
                           user: employee, leave: leave,
                           applied_from: from,
                           applied_till: till || from,
                           leave_duration_type: described_class::LEAVE_DURATION[duration])
  end

  describe 'initial state' do
    it 'starts pending' do
      expect(apply).to be_pending
    end
  end

  describe 'validation' do
    it 'rejects an application starting in the past' do
      record = build(:applied_leave, company: company, user_leave: balance,
                                     user: employee, leave: leave,
                                     applied_from: Date.today - 3,
                                     applied_till: Date.today - 1)
      expect(record).not_to be_valid
    end

    it 'rejects an end date before the start date' do
      record = build(:applied_leave, company: company, user_leave: balance,
                                     user: employee, leave: leave,
                                     applied_from: next_monday + 3,
                                     applied_till: next_monday)
      expect(record).not_to be_valid
    end

    it 'accepts a single upcoming weekday' do
      expect(apply).to be_valid
    end

    it 'rejects a duration type that is not one of the two offered' do
      record = build(:applied_leave, company: company, user_leave: balance,
                                     user: employee, leave: leave,
                                     leave_duration_type: 99)

      expect(record).not_to be_valid
      expect(record.errors[:leave_duration_type]).to be_present
    end

    # Asserting the validation alone would not show why it matters: the bare
    # key resolves to the whole subtree, and the view prints that hash.
    it 'would otherwise translate the bare key into a hash' do
      record = build(:applied_leave, company: company, user_leave: balance,
                                     user: employee, leave: leave,
                                     leave_duration_type: 99)

      expect(record.leave_duration_name).to be_nil
      expect(I18n.t("applied_leave.links.#{record.leave_duration_name}")).to be_a(Hash)
    end

    # Rails runs custom validators alongside the presence validator rather than
    # after it, so a cleared field reaches these comparisons as nil.
    %i[applied_from applied_till].each do |field|
      it "reports a blank #{field} instead of raising" do
        record = build(:applied_leave, company: company, user_leave: balance,
                                       user: employee, leave: leave,
                                       applied_from: next_monday,
                                       applied_till: next_monday)
        record[field] = nil

        expect { record.valid? }.not_to raise_error
        expect(record.errors[field]).to be_present
      end
    end
  end

  describe 'counting days' do
    it 'counts only weekdays' do
      # Monday to the following Monday spans 8 days but only 6 weekdays.
      applied = apply(from: next_monday, till: next_monday + 7)
      applied.approve_applied_leave

      expect(balance.reload.remaining_count).to eq(14.0)
    end

    it 'counts a half day as half' do
      applied = apply(duration: :half_day)
      applied.approve_applied_leave

      expect(balance.reload.remaining_count).to eq(19.5)
    end

    it 'ignores a weekend-only window' do
      saturday = next_monday + 5
      applied  = build(:applied_leave, company: company, user_leave: balance,
                                       user: employee, leave: leave,
                                       applied_from: saturday, applied_till: saturday + 1,
                                       leave_duration_type: described_class::LEAVE_DURATION[:full_day])
      applied.save!

      expect(applied.leave_available?).to be(false)
    end
  end

  describe '#approve_applied_leave' do
    it 'moves the application to accepted' do
      applied = apply
      expect(applied.approve_applied_leave).to be(true)
      expect(applied.reload).to be_accepted
    end

    it 'deducts the days from the remaining balance' do
      applied = apply(from: next_monday, till: next_monday + 2)

      expect { applied.approve_applied_leave }
        .to change { balance.reload.remaining_count }.from(20.0).to(17.0)
    end

    it 'leaves the total allowance untouched' do
      apply.approve_applied_leave
      expect(balance.reload.total_count).to eq(20.0)
    end

    it 'refuses a second approval' do
      applied = apply
      applied.approve_applied_leave

      expect(applied.approve_applied_leave).to be(false)
      expect(applied.errors.full_messages).to be_present
    end

    it 'refuses when the balance cannot cover the request' do
      balance.update!(remaining_count: 1.0)
      applied = apply(from: next_monday, till: next_monday + 4)

      expect(applied.approve_applied_leave).to be(false)
      expect(applied.reload).to be_pending
      expect(balance.reload.remaining_count).to eq(1.0)
    end
  end

  # An allowance is spent when the balance reaches zero, so the last day has to
  # be both requestable and saveable. Two separate rules stopped it: the
  # balance check refused a request equal to what was left, and the balance
  # itself would not validate at zero.
  describe 'spending the final day of an allowance' do
    # A single-day allowance of its own, so the shared 20-day balance stays
    # available to the rest of the file.
    def one_day_balance
      create(:user_leave, company: company, user: employee,
                          leave: create(:leave, company: company, default_count: 1.0),
                          total_count: 1.0, remaining_count: 1.0)
    end

    it 'counts a request for exactly the remaining balance as available' do
      expect(one_day_balance.count_available?(1.0)).to be(true)
    end

    it 'refuses a request for more than the remaining balance' do
      expect(one_day_balance.count_available?(2.0)).to be(false)
    end

    it 'approves the request and empties the balance' do
      remaining = one_day_balance
      applied   = create(:applied_leave, company: company, user_leave: remaining,
                                         user: employee, leave: remaining.leave,
                                         applied_from: next_monday, applied_till: next_monday,
                                         leave_duration_type: described_class::LEAVE_DURATION[:full_day])

      expect(applied.approve_applied_leave).to be(true)
      expect(remaining.reload.remaining_count).to eq(0.0)
    end
  end

  describe '#reject_applied_leave' do
    it 'moves the application to rejected' do
      applied = apply
      expect(applied.reject_applied_leave).to be(true)
      expect(applied.reload).to be_rejected
    end

    it 'does not touch the balance' do
      applied = apply

      expect { applied.reject_applied_leave }
        .not_to change { balance.reload.remaining_count }
    end

    it 'refuses to reject an already accepted application' do
      applied = apply
      applied.approve_applied_leave

      expect(applied.reject_applied_leave).to be(false)
    end
  end

  describe 'bulk actions' do
    it 'approves every pending application it is given' do
      ids = Array.new(3) { apply(from: next_monday + 1) }.map(&:id)

      expect(described_class.approve_mass_leaves(id: ids)).to eq(3)
      expect(described_class.where(id: ids).pluck(:state).uniq).to eq(['accepted'])
    end

    it 'counts only the ones it could actually approve' do
      approvable = apply(from: next_monday)
      already    = apply(from: next_monday + 1)
      already.approve_applied_leave

      count = described_class.approve_mass_leaves(id: [approvable.id, already.id])

      expect(count).to eq(1)
    end

    it 'rejects every pending application it is given' do
      ids = Array.new(2) { apply(from: next_monday + 1) }.map(&:id)

      expect(described_class.reject_mass_leaves(id: ids)).to eq(2)
      expect(described_class.where(id: ids).pluck(:state).uniq).to eq(['rejected'])
    end
  end

  describe 'deletion' do
    it 'allows a pending application to be withdrawn' do
      applied = apply
      expect(applied.destroy).to be_truthy
    end

    it 'refuses to delete an application that was already decided' do
      applied = apply
      applied.approve_applied_leave

      expect(applied.reload.destroy).to be(false)
      expect(described_class.exists?(applied.id)).to be(true)
    end
  end

  describe '.get_filtered_records' do
    it 'filters by state' do
      pending_leave  = apply(from: next_monday)
      rejected_leave = apply(from: next_monday + 1)
      rejected_leave.reject_applied_leave

      expect(described_class.get_filtered_records('rejected').pluck(:id)).to eq([rejected_leave.id])
      expect(described_class.get_filtered_records('pending').pluck(:id)).to eq([pending_leave.id])
    end

    it 'returns everything for an unknown filter' do
      apply
      expect(described_class.get_filtered_records('nonsense').count).to eq(1)
    end

    it 'returns everything for an empty filter' do
      apply
      expect(described_class.get_filtered_records('').count).to eq(1)
    end
  end
end
