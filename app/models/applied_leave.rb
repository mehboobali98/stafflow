class AppliedLeave < ApplicationRecord
  include ActiveModel::Transitions
  LEAVE_DURATION = HashWithIndifferentAccess.new({ full_day: 1, half_day: 2 }).freeze
  validates :applied_from, :applied_till, presence: true
  validate :validate_past_leave_date, on: :create
  validate :validate_leave_dates
  belongs_to :user_leave
  belongs_to :user
  belongs_to :leave
  belongs_to :company
  before_destroy :can_delete_leave?, prepend: true
  after_create :send_request_email
  after_create :create_request_notification

  def can_delete_leave?
    return true if pending?

    errors.add(:base, I18n.t('applied_leave.messages.error.delete_error'))
    throw(:abort)
  end

  def leave_duration_name
    LEAVE_DURATION.invert[leave_duration_type]
  end

  def set_leave
    return false if user_leave.nil?

    self.leave_id = user_leave.leave.id
    true
  end

  def leave_available?
    binding.pry
    leave_count = calculate_leave_count
    return true if leave_count.positive? && user_leave.count_available?(leave_count)

    errors.add(:leave_count, I18n.t('applied_leave.messages.error.leave_count'))
    false
  end

  def self.approve_mass_leaves(applied_leave_ids)
    count_approved = 0
    applied_leaves = where(applied_leave_ids)
    applied_leaves.each do |applied_leave|
      count_approved += 1 if applied_leave.approve_applied_leave
    rescue ActiveRecord::RecordNotFound
      count_approved
    end
    count_approved
  end

  def approve_applied_leave
    ActiveRecord::Base.transaction do
      request_accepted! # change state
      true
    rescue Transitions::InvalidTransition
      errors.add(:base, I18n.t('applied_leave.messages.error.approve_error'))
    rescue ArgumentError
      errors.add(:base, I18n.t('applied_leave.messages.error.leave_count_error'))
      false
    rescue ActiveRecord::RecordInvalid
      false
    end
  end

  def reject_applied_leave
    request_rejected! # change state
    true
  rescue Transitions::InvalidTransition
    errors.add(:base, I18n.t('applied_leave.messages.error.approve_error'))
    false
  rescue ActiveRecord::RecordInvalid
    false
  end

  def self.reject_mass_leaves(applied_leave_ids)
    count_rejected = 0
    applied_leaves = where(applied_leave_ids)
    applied_leaves.each do |applied_leave|
      count_rejected += 1 if applied_leave.reject_applied_leave
    rescue ActiveRecord::RecordNotFound
      count_rejected
    end
    count_rejected
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
    return all if filter.empty? || filter_not_exists?(filter)

    where(state: filter)
  end

  def self.filter_not_exists?(filter)
    return true unless filter.to_sym.in?(available_states)

    false # exists
  end

  state_machine initial: :pending do
    state :pending # first one is initial state
    state :accepted
    state :rejected

    event :request_accepted, success: %i[create_approval_notification send_approval_email] do
      transitions to: :accepted, from: :pending, guard: :validate_leave_count, on_transition: :approve_leave
    end
    event :request_rejected, success: %i[create_rejection_notification send_rejection_email] do
      transitions to: :rejected, from: :pending
    end
  end

  def validate_leave_count
    raise ArgumentError unless leave_available?
  end

  def approve_hr_added_leave
    ActiveRecord::Base.transaction do
      set_leave
      update_leave_count(calculate_leave_count)
      save!
      user_leave.save!
      request_accepted!
      true
    rescue Transitions::InvalidTransition
      errors.add(:base, I18n.t('applied_leave.messages.error.approve_error'))
      false
    rescue ActiveRecord::RecordInvalid
      false
    end
  end

  private

  def send_request_email
    recipients_ids = get_admins.pluck(:id)
    LeaveMailer.delay.request_email(recipients_ids, user.id, id, user.company.id)
  end

  def send_approval_email
    recipients_ids = get_admins.pluck(:id)
    LeaveMailer.delay.approve_email(recipients_ids, user.id, id, user.company.id)
  end

  def send_rejection_email
    recipients_ids = get_admins.pluck(:id)
    LeaveMailer.delay.rejection_email(recipients_ids, user.id, id, user.company.id)
  end

  def create_approval_notification
    body = I18n.t('notifications.leave_approve_self', from: applied_from, to: applied_till)
    Notification.create(recipient_id: user.id, body: body)
  end

  def create_rejection_notification
    body = I18n.t('notifications.leave_reject_self', from: applied_from, to: applied_till)
    Notification.create(recipient_id: user.id, body: body)
  end

  def create_request_notification
    body = I18n.t('notifications.new_leave', full_name: user.full_name)
    admin_ids = get_admins.pluck(:id)
    admin_ids.each do |id|
      Notification.create(recipient_id: id, body: body)
    end
  end

  def get_admins
    company.users.where(role_id: User::ROLES[:department_head])
           .where(department_id: user.department_id)
           .or(user.company.users.where(role_id: [User::ROLES[:hr], User::ROLES[:account_owner]]))
           .where.not(id: user.id)
  end

  def approve_leave
    update_leave_count(calculate_leave_count)
    save!
    user_leave.save!
  end

  def calculate_leave_count
    number_of_days = week_days_count(applied_from..applied_till)
    return number_of_days if leave_duration_name.eql?(:full_day)

    number_of_days / 2.0 # dividing for half-day
  end

  def update_leave_count(leave_count)
    user_leave.remaining_count -= leave_count
  end

  def week_days_count(date_range)
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
