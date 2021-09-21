class AppliedLeave < ApplicationRecord
  include ActiveModel::Transitions
  LEAVE_DURATION = HashWithIndifferentAccess.new({ full_day: 1, half_day: 2 }.freeze)
  validates :applied_from, :applied_till, presence: true
  validate :validate_past_leave_date, on: :create
  validate :validate_leave_dates
  belongs_to :user_leave
  belongs_to :user
  belongs_to :leave
  belongs_to :company

  def leave_duration_name
    LEAVE_DURATION.invert[leave_duration_id]
  end

  def leave_available?
    leave_count = calculate_leave_count
    return true if leave_count.positive? && leave_count < user_leave.remaining_count

    errors.add(:leave_count, I18n.t('applied_leave.messages.error.leave_count'))
    false
  end

  def approve_applied_leave
    request_accepted! # change state
    true
  rescue Transitions::InvalidTransition
    errors.add(:base, I18n.t('applied_leave.messages.error.approve_error'))
    false
  rescue ArgumentError
    errors.add(:base, I18n.t('applied_leave.messages.error.leave_count_error'))
    false
  end

  def reject_applied_leave
    request_rejected! # change state
    true
  rescue Transitions::InvalidTransition
    errors.add(:base, I18n.t('applied_leave.messages.error.approve_error'))
    false
  end

  def self.approve_multiple_applied_leaves(applied_leave_ids)
    applied_leaves = find(applied_leave_ids)
    applied_leaves.each do |applied_leave|
      applied_leave.approve_applied_leave
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  def self.reject_multiple_applied_leaves(applied_leave_ids)
    applied_leaves = find(applied_leave_ids)
    applied_leaves.each do |applied_leave|
      applied_leave.reject_applied_leave
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  def validate_leave_year
    validate_date_year(applied_from) && validate_date_year(applied_till)
  end

  def validate_past_leave_date
    return true unless applied_from < Date.today && applied_till < Date.today

    errors.add(:leave_date, I18n.t('applied_leave.messages.error.past_leave_date'))
    false
  end

  def validate_leave_dates
    return true unless applied_till < applied_from

    errors.add(:ending_leave_date, I18n.t('applied_leave.messages.error.end_leave_date'))
    false
  end

  def self.get_filtered_records(filter)
    return all if filter.empty? && filter_not_exists?(filter)

    where(state: filter)
  end

  def self.filter_not_exists?(filter)
    return true unless filter.to_sym.in?(available_states)

    false # exists
  end

  state_machine do
    state :pending # first one is initial state
    state :accepted
    state :rejected

    event :request_accepted do
      transitions to: :accepted, from: :pending, guard: :guard_condition, on_transition: :approve_leave
    end
    event :request_rejected do
      transitions to: :rejected, from: :pending
    end
  end

  private

  def approve_leave
    ActiveRecord::Base.transaction do
      update_remaining_leave_count(calculate_leave_count)
      save!
      user_leave.save!
    rescue ActiveRecord::RecordInvalid
      nil
    end
  end

  def guard_condition
    calculate_leave_count.positive?
  end

  def event_failed(_event)
    raise ArgumentError
  end

  def calculate_leave_count
    number_of_days = week_days_in_date_range(applied_from..applied_till)
    return number_of_days if leave_duration_name.eql?(:full_day)

    number_of_days / 2.0
  end

  def update_remaining_leave_count(leave_count)
    user_leave.remaining_count -= leave_count
  end

  def week_days_in_date_range(date_range)
    date_range.select { |day| (1..5).include?(day.wday) }.size
  end

  def validate_date_year(leave_date)
    return true unless Date.parse(leave_date.to_s).year.to_s.length > 4

    errors.add(:leave_date_year, I18n.t('applied_leave.messages.error.leave_date_year'))
    false
  rescue Date::Error
    errors.add(:leave_date, I18n.t('applied_leave.messages.error.invalid_date'))
    false
  end
end
