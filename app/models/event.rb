# frozen_string_literal: true

require 'date'

# event model
class Event < ApplicationRecord
  validates :name, presence: true
  validate :validate_past_event_date, on: :create

  def validate_past_event_date
    errors.add(:event_date, 'cannot be in the past') if starts_at < DateTime.now
  end

  private :validate_past_event_date
end
