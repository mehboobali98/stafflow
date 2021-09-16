class AppliedLeave < ApplicationRecord
  include ActiveModel::Transitions
  belongs_to :user_leave
  belongs_to :user
  belongs_to :leave
  LEAVE_DURATION = { full_day: 1, half_day: 2 }.freeze
  validates :applied_at, :applied_till, presence: true
  validate :validate_past_leave_date
  validate :validate_leave_dates

  def leave_duration_name_from_id
    LEAVE_DURATION.invert[leave_duration_id]
  end

  def calculate_leave_count
    number_of_days = week_days_in_date_range(applied_at..applied_till)
    return number_of_days if leave_duration_name_from_id.eql?(:full_day)

    number_of_days / 2 unless number_of_days.nil?
  end

  def week_days_in_date_range(date_range)
    date_range.select { |day| (1..5).include?(day.wday) }.size
  end

  def leave_count_available?
    return true if calculate_leave_count < user_leave.remaining_count

    errors.add(:leave_count, I18n.t('applied_leave.messages.error.leave_count'))
    false
  end

  def update_remaining_leave_count(leave_count)
    user_leave.remaining_count -= leave_count
  end

  def approve_applied_leave
    leave_count = calculate_leave_count
    return false unless pending? && leave_count.positive?

    ActiveRecord::Base.transaction do
      request_accepted # change state
      update_remaining_leave_count(leave_count)
      save!
      user_leave.save!
      true
    rescue ActiveRecord::RecordInvalid
      false
    end
  end

  def reject_applied_leave
    return false unless pending?

    request_rejected # change state
    save
  end

  def validate_leave_year
    validate_date_year(applied_at) && validate_date_year(applied_till)
  end

  def validate_date_year(leave_date)
    return true unless Date.parse(leave_date.to_s).year.to_s.length > 4

    errors.add(:leave_date_year, I18n.t('applied_leave.messages.error.leave_date_year'))
    false
  rescue Date::Error => e
    errors.add(e.message)
    false
  end

  def self.approve_multiple_applied_leaves(applied_leave_ids)
    applied_leave_ids.each do |leave_id|
      applied_leave = AppliedLeave.find(leave_id)
      applied_leave.approve_applied_leave
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  def self.reject_multiple_applied_leaves(applied_leave_ids)
    applied_leave_ids.each do |leave_id|
      applied_leave = AppliedLeave.find(leave_id)
      applied_leave.reject_applied_leave
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  def validate_past_leave_date
    return true unless applied_at < Date.today && applied_till < Date.today

    errors.add(:leave_date, I18n.t('applied_leave.messages.error.past_leave_date'))
    false
  end

  def validate_leave_dates
    return true unless applied_till < applied_at

    errors.add(:ending_leave_date, I18n.t('applied_leave.messages.error.end_leave_date'))
    false
  end

  def self.get_filtered_records(filter)
    return AppliedLeave.all if filter.empty?

    AppliedLeave.where(state: filter)
  end

  def self.get_applied_leaves
    AppliedLeave.includes(user_leave: %i[user leave])
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
