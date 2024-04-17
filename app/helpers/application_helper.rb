# frozen_string_literal: true

module ApplicationHelper
  def flipper_check(flipper_name, email)
    Flipper.enabled?(flipper_name, Flipper::Actor.new(email))
  end

  def table_row_top(start_time)
    shift_start_time = 8
    (start_time - shift_start_time) * Meeting::HOUR_HEIGHT_IN_PX
  end

  def morning_shift_count(meetings)
    meetings.select(&:morning_shift?).count
  end

  def evening_shift_count(meetings)
    meetings.select(&:evening_shift?).count
  end

  def morning_shifts(meetings)
    meetings.select(&:morning_shift?)
  end

  def dinner_shifts(meetings)
    meetings.select(&:evening_shift?)
  end
end
