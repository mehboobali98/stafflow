# frozen_string_literal: true

# event model
class Event < ApplicationRecord
  belongs_to :company

  validates :name, presence: true
  validates :starts_at, presence: true
  validate :validate_past_event_date, on: :create

  def self.events_in_a_month(date)
    where(starts_at: date.beginning_of_month..date.next_month.prev_day)
  end

  def validate_event_year(event_date)
    return true unless Date.parse(event_date).year.to_s.length > 4

    errors.add(:event_year, I18n.t('event.messages.error.event_year'))
    false
  rescue TypeError
    errors.add(:event_date, I18n.t('event.messages.error.nil_date_input'))
    false
  rescue Date::Error
    errors.add(:event_date, I18n.t('event.messages.error.invalid_date'))
    false
  end

  # method required for simple_calendar gem as it uses start_time
  # as default attribute to create calendar
  def start_time
    starts_at
  end

  private

  def validate_past_event_date
    return true if starts_at.blank?
    return true unless starts_at < DateTime.now

    errors.add(:event_date, I18n.t('event.messages.error.event_date'))
    false
  end
end
