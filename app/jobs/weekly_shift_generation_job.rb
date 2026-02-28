# frozen_string_literal: true

class WeeklyShiftGenerationJob < ApplicationJob
  queue_as :default

  def perform(location_id)
    target_week = (Date.today + 1.day).beginning_of_week..(Date.today + 1.day).end_of_week
    ShiftGenerationService.new(location_id, target_week.to_a).call
  end
end
