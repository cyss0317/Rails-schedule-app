# frozen_string_literal: true

module DateHelper
  require 'date'

  def fetch_time_from_date(date)
    date.strftime('%l:%M %p')
  end

  def fetch_date_from_date(date)
    date.strftime('%b %d, %Y')
  end

  def time_from_to(start_date, end_date)
    "#{fetch_time_from_date(start_date)} - #{fetch_time_from_date(end_date)}"
  end

  def current_time
    Time.now.in_time_zone
  end

  def current_time_hour
    current_time.hour
  end

  def number_month_to_string(month)
    Date::MONTHNAMES[month]
  end

  def format_date(date)
    date.strftime('%b %d, %Y %l:%M %p')
  end
end
