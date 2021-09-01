# frozen_string_literal: true

require 'date'

# event model
class Event < ApplicationRecord
  attr_accessor :start_date_str, :start_time_str

  before_save :set_event_start_date_time

  validates :name, :start_date_str, :start_time_str, presence: true
  validate :date_is_valid?

  def date_is_valid?
    set_event_start_date_time
    errors.add(:start, 'Cannot add event in the past') if start_time < DateTime.now
  end

  def set_start_date_str(event_date_time)
    @start_date_str = event_date_time.to_date
  end

  def set_start_time_str(event_date_time)
    @start_time_str = Time.parse(event_date_time.strftime('%H:%M %p'))
  end

  def set_event_start_date_time
    binding.pry
    self.start_time = DateTime.parse("#{@start_date_str} #{@start_time_str}") if @start_date_str && @start_time_str
  end
end
