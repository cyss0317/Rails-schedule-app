# frozen_string_literal: true

module TimeHelper
  def idx_to_time(idx)
    return 12 if idx.zero?

    if idx < 12
      idx
    elsif idx > 12
      idx - 12
    else
      12
    end
  end

  def correct_minute(min)
    min.zero? ? '00' : min
  end

  def am_pm(time)
    time.hour < 12 ? 'AM' : 'PM'
  end

  def time_in_am_pm(time)
    time.hour < 12 ? "#{idx_to_time(time.hour)}:#{correct_minute(time.min)}AM" : "#{idx_to_time(time.hour)}:#{correct_minute(time.min)}PM"
  end

  def time_from_to(start_time, end_time)
    "#{time_in_am_pm(start_time)} - #{time_in_am_pm(end_time)}"
  end
end
