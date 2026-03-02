# frozen_string_literal: true

# Copies all meetings from the week immediately preceding the target week.
# Day-of-week mapping is preserved (Mon → Mon, Tue → Tue, etc.).
# Skips meetings that already exist in the target week (duplicate guard).
# Skips users with a conflicting day off.
#
# Returns the list of meetings that could not be copied due to day-off conflicts.
class PasteLastWeekService
  def initialize(location_id, target_week)
    @location_id = location_id
    @target_week = target_week
  end

  def call
    source_date = @target_week.first - 7.days
    unable_list = []
    Meeting.copy_week_meetings_from_source(source_date, @target_week, @location_id, unable_list)
    unable_list
  end
end
