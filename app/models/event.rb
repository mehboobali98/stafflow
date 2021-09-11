# frozen_string_literal: true

# event model
class Event < ApplicationRecord
  validates :name, presence: true
  validate :validate_past_event_date, on: :create
  scope :events_in_a_month, ->(month) { where('extract(month from starts_at) = ?', month) }

  def self.get_events_in_a_month(month)
    Event.events_in_a_month(month)
  end

  def validate_event_year(event_date)
    return true unless Date.parse(event_date).year.to_s.length > 4

    errors.add(:event_year, I18n.t('event.messages.error.event_year'))
    false
  rescue Date::Error => e
    errors.add(e.message)
    false
  end

  def validate_past_event_date
    errors.add(:event_date, I18n.t('event.messages.error.event_date')) if starts_at < DateTime.now
  end

  def start_time
    starts_at
  end

  private :validate_past_event_date
end
