# frozen_string_literal: true

class WeeklyShiftGenerationJob < ApplicationJob
  queue_as :default

  # When called with no argument (recurring schedule) — generates shifts for
  # every location. When called with a specific location_id (manual trigger or
  # tests) — generates only for that location.
  def perform(location_id = nil)
    # beginning_of_week + 7 days always yields next Monday regardless of the
    # current weekday. The old formula (Date.today + 1).beginning_of_week was
    # wrong on Fri/Sat — it rolled back to the start of the *current* week.
    target_week_start = Date.today.beginning_of_week + 7.days
    target_week       = (0..6).map { |i| target_week_start + i }

    location_ids = location_id ? [location_id] : Location.pluck(:id)
    location_ids.each { |lid| ShiftGenerationService.new(lid, target_week).call }
  end
end
