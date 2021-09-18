# frozen_string_literal: true

# Event helper
module EventsHelper
  def format_date(date)
    date&.strftime('%d-%B-%Y    %k:%M %p')
  end

  def extract_time(date)
    return Time.now.strftime('%H:%M') if date.nil?

    date.strftime('%H:%M')
  end

  def extract_date(date)
    return Date.today if date.nil?

    date.to_date
  end

  def set_event_date(date, params)
    return params[:event_date] if params.key?(:event_date)

    extract_date(date)
  end

  def truncate_event_name(name)
    name.truncate(TRUNCATE_LENGTH)
  end
end
