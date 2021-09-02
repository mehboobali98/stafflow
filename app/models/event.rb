# frozen_string_literal: true

require 'date'

# event model
class Event < ApplicationRecord
  attr_accessor :start_date_str, :start_time_str

  before_validation :set_event_start_date_time

  validates :name, :start_date_str, :start_time_str, presence: true
  validate :event_date_cannot_be_in_past, :event_date_cannot_be_in_next_century

  def event_date_cannot_be_in_past
    errors.add(:event_start_date, 'cannot be in the past') if start_time < DateTime.now
  end

  def event_date_cannot_be_in_next_century
    errors.add(:event_start_date, 'cannot be in the next century') if start_time.year.to_s.length > 4
  end

  def set_start_date
    @start_date_str = start_time.to_date
  end

  def set_start_time
    @start_time_str = Time.parse(start_time.strftime('%H:%M %p'))
  end

  def set_event_start_date_time
    if @start_date_str && @start_time_str
      self.start_time = DateTime.strptime("#{@start_date_str} #{@start_time_str}",
                                          '%Y-%m-%d %H:%M')
    end
  rescue Date::Error
    throw :abort
  end
end
