# frozen_string_literal: true

# event model
class Event < ApplicationRecord
  validates :name, presence: true
  validate :validate_past_event_date, on: :create

  def validate_event_year(event_date)
    return true unless Date.parse(event_date).year.to_s.length > 4

    errors.add(:event_year, I18n.t('event.messages.error.event_year'))
    false
  rescue Date::Error => e
    errors.add(e.message)
    false
  end

  def validate_past_event_date
    return true unless starts_at < DateTime.now

    errors.add(:event_date, I18n.t('event.messages.error.event_date'))
    false
  end

  def start_time
    starts_at
  end

  private :validate_past_event_date
end
