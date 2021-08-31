require 'date'

class Event < ApplicationRecord
  before_save :set_event_start_date_time, :set_event_end_date_time
  attr_accessor :start_date_str, :start_time_str, :end_date_str, :end_time_str

  def self.convert_to_date(date)
    Date.parse(date.strftime('%m/%d/%Y'))
  end

  def self.convert_to_time(time)
    Time.parse(time.strftime('%H:%M'))
  end

  def set_event_start_date_time
    self.start_time = DateTime.parse("#{@start_date_str} #{@start_time_str}") if @start_date_str && @start_time_str
  end

  def set_event_end_date_time
    self.end_time = DateTime.parse("#{@end_date_str} #{@end_time_str}") if @end_date_str && @end_time_str
  end
end
