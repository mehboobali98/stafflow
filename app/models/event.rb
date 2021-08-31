require 'date'

class Event < ApplicationRecord
  before_save :set_start_date_time, :set_end_date_time
  attr_writer :start_date, :start_time, :end_date, :end_time

  def start_date
    start_date_time&.strftime('%m/%d/%Y')
  end

  def start_time
    start_date_time&.strftime('%H:%M')
  end

  def end_date
    end_date_time&.strftime('%m/%d/%Y')
  end

  def end_time
    end_date_time&.strftime('%H:%M') unless end_date_time.is_a?(String)
  end

  def set_start_date_time
    self.start_date_time = DateTime.parse("#{@start_date} #{@start_time}") if @start_date && @start_time
  end

  def set_end_date_time
    self.end_date_time = DateTime.parse("#{@end_date} #{@end_time}") if @end_date && @end_time
  end
end
