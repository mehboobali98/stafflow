# frozen_string_literal: true

require 'date'

# event model
class Event < ApplicationRecord
  before_save :set_event_start_date_time
  attr_accessor :start_date_str, :start_time_str

  validates :name, presence: true

  def self.convert_to_time(time)
    Time.parse(time.strftime('%H:%M'))
  end

  def set_event_start_date_time
    self.start_time = DateTime.parse("#{@start_date_str} #{@start_time_str}") if @start_date_str && @start_time_str
  end
end
