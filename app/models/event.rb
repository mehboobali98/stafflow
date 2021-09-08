# frozen_string_literal: true

# event model
class Event < ApplicationRecord
  validates :name, presence: true
  validate :validate_past_event_date, on: :create

  def validate_event_year(event_date)
    if Date.parse(event_date).year.to_s.length > 4
      errors.add(:event_year, 'cannot have more than 4 digits')
      false
    else
      true
    end
  rescue Date::Error => e
    errors.add(e.message)
    false
  end

  def validate_past_event_date
    errors.add(:event_date, 'cannot be in the past') if starts_at < DateTime.now
  end

  private :validate_past_event_date
end
