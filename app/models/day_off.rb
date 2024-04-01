class DayOff < ApplicationRecord
  belongs_to :user

  def off_dates
    (start_time.to_date..end_time.to_date).to_a
  end
end
