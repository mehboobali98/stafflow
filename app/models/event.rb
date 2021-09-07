# frozen_string_literal: true

require 'date'

# event model
class Event < ApplicationRecord
  validates :name, presence: true
  validate :validate_past_event_date, on: :create
  validate :validate_event_year

  def validate_past_event_date
    errors.add(:event_date, 'cannot be in the past') if starts_at < DateTime.now
  end

  def validate_event_year
    errors.add(:event_year, 'cannot have more than 4 digits') if starts_at.year.to_s.length > 4
  end

  def set_event_fields(event_params)
    self.name = event_params[:name]
    self.starts_at = "#{event_params[:event_date]} #{event_params[:event_time]}"
  end

  private :validate_past_event_date, :validate_event_year
end
