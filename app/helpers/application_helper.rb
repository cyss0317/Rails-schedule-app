# frozen_string_literal: true

module ApplicationHelper
  def table_row_top(start_time)
    shift_start_time = 8
    (start_time - shift_start_time) * 100
  end

  def morning_shift_count(meetings)
    meetings.select(&:morning_shift?).count
  end

  def evening_shift_count(meetings)
    meetings.select(&:evening_shift?).count
  end
end
