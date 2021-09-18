# frozen_string_literal: true

# event model
class Event < ApplicationRecord
  validates :name, presence: true
  validate :validate_past_event_date, on: :create

  def self.events_in_a_month(date)
    Event.where(starts_at: date.beginning_of_month..date.end_of_month)
  end

  def validate_event_year(event_date)
    return true unless Date.parse(event_date).year.to_s.length > 4

    errors.add(:event_year, I18n.t('event.messages.error.event_year'))
    false
  rescue Type::Error
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
    return true unless starts_at < DateTime.now

    errors.add(:event_date, I18n.t('event.messages.error.event_date'))
    false
  end
end
