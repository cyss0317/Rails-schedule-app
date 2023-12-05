module DateHelper
  def fetch_time_from_date(date)
    date.strftime('%l:%M %p')
  end

  def fetch_date_from_date(date)
    date.strftime('%b %d, %Y')
  end

  def time_from_to(start_date, end_date)
    "#{fetch_time_from_date(start_date)} - #{fetch_time_from_date(end_date)}"
  end

  def format_date(date)
    date.strftime('%b %d, %Y %l:%M %p')
  end
end
