# frozen_string_literal: true

module EventsHelper
  def format_date(date)
    date.strftime('%d-%B-%Y    %k:%M %p')
  end
end
