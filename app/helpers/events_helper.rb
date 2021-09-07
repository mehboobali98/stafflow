# frozen_string_literal: true

# Event helper
module EventsHelper
  def format_date(date)
    date&.strftime('%d-%B-%Y    %k:%M %p')
  end

  def extract_time(date)
    date&.strftime('%H:%M') unless date.nil?
  end

  def extract_date(date)
    date&.to_date unless date.nil?
  end
end
