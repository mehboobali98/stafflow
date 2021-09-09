class AppliedLeave < ApplicationRecord
  include ActiveModel::Transitions
  belongs_to :user_leave
  LEAVE_DURATION = { 'Full day': 1, 'Half day': 2 }.freeze

  def leave_duration_name_from_id
    LEAVE_DURATION.invert[leave_duration_id]
  end

  def calculate_leave_count
    number_of_days = week_days_in_date_range(applied_at..applied_till)
    return number_of_days unless leave_duration_name_from_id.eql?('Full day'.to_sym)

    number_of_days / 2 unless number_of_days.nil?
  end

  def week_days_in_date_range(date_range)
    date_range.select { |day| (1..5).include?(day.wday) }.size
  end

  def leave_count_available?
    return true if calculate_leave_count < user_leave.remaining_count

    errors.add(:leave_count, 'is greater than the remaining count of leaves. Request rejected.')
    false
  end

  def update_remaining_leave_count
    user_leave.remaining_count -= calculate_leave_count
  end

  def current_state_pending?
    pending?
  end

  def approve_applied_leave
    return false unless state.eql?('pending')

    ActiveRecord::Base.transaction do
      request_accepted # change state
      update_remaining_leave_count
      save!
      user_leave.save!
      true
    rescue ActiveRecord::RecordInvalid
      false
    end
  end

  state_machine do
    state :pending # first one is initial state
    state :accepted
    state :rejected

    event :request_accepted do
      transitions to: :accepted, from: :pending
    end
    event :request_rejected do
      transitions to: :rejected, from: :pending
    end
  end
end
