# frozen_string_literal: true

module ApplicationHelper
  def table_row_top(start_time)
    shift_start_time = 8
    (start_time - shift_start_time) * 100
  end
end
