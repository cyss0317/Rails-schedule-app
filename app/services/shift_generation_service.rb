# frozen_string_literal: true

# Generates a standard week of shifts for all active users at a location.
# Morning: 9AM–3PM CST (2 employees). Evening: 3PM–9PM CST (2 employees).
# Skips users with conflicting day offs and avoids duplicates.
class ShiftGenerationService
  MORNING_START = 9
  MORNING_END   = 15
  EVENING_START = 15
  EVENING_END   = 21
  TZ            = 'America/Chicago'

  def initialize(location_id, target_week)
    @location_id = location_id
    @target_week = target_week
  end

  def call
    users = User.joins(:location_users)
                .where(location_users: { location_id: @location_id, active: true })
                .without_demo_user.sort_by_first_name

    morning_pool = users.first(2)
    evening_pool = users.last(2)

    @target_week.each do |date|
      morning_pool.each do |user|
        start_t = date.in_time_zone(TZ).change(hour: MORNING_START)
        end_t   = date.in_time_zone(TZ).change(hour: MORNING_END)
        create_if_available(user, start_t, end_t, date)
      end
      evening_pool.each do |user|
        start_t = date.in_time_zone(TZ).change(hour: EVENING_START)
        end_t   = date.in_time_zone(TZ).change(hour: EVENING_END)
        create_if_available(user, start_t, end_t, date)
      end
    end
  end

  private

  def create_if_available(user, start_t, end_t, date)
    return unless user.can_work_for_time_frame?(start_t, end_t, date)
    return if Meeting.filter_by_location_id(@location_id)
                     .where(user_id: user.id, start_time: start_t, end_time: end_t)
                     .exists?

    Meeting.create!(start_time: start_t, end_time: end_t, user_id: user.id, location_id: @location_id)
  end
end
