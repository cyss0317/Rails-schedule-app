# frozen_string_literal: true

# Generates exactly 2 morning and 2 evening shifts for every day of the
# target week by identifying which active users historically work each type.
#
# Algorithm:
#   1. Look back LOOKBACK_WEEKS (4) weeks of past meetings at this location.
#   2. Count each user's total morning and evening shift occurrences.
#   3. Rank ALL historical workers by count (morning and evening separately).
#   4. For each day, fill 2 morning slots and 2 evening slots in ranked order.
#      If a top worker has a day off, the next-ranked worker fills in.
#   5. Fallback: if no historical data exists, first 2 active users → morning,
#      last 2 → evening (round-robin), with remaining users as backups.
#   6. Skip entirely if any shifts already exist for the target week.
#
# Shift windows (CST / America/Chicago):
#   Morning → 9 AM – 3 PM
#   Evening → 3 PM – 9 PM
#
# Both windows align with Meeting#morning_shift? and Meeting#evening_shift?.
class ShiftGenerationService
  MORNING_START   = 9
  MORNING_END     = 15
  EVENING_START   = 15
  EVENING_END     = 21
  TZ              = 'America/Chicago'
  LOOKBACK_WEEKS  = 4
  SLOTS_PER_SHIFT = 2

  def initialize(location_id, target_week)
    @location_id = location_id
    @target_week = target_week
  end

  def call
    if target_week_already_scheduled?
      Rails.logger.info("[ShiftGenerationService] Skipping location #{@location_id} — shifts already exist for #{@target_week.first}..#{@target_week.last}.")
      return
    end

    users = active_users
    morning_ranked, evening_ranked = determine_shift_workers(users)

    if morning_ranked.empty? && evening_ranked.empty?
      Rails.logger.info("[ShiftGenerationService] No historical data for location #{@location_id}. Using default round-robin.")
      morning_ranked = users.to_a
      evening_ranked = users.to_a.reverse
    end

    Rails.logger.info(
      "[ShiftGenerationService] location #{@location_id}: " \
      "morning=#{morning_ranked.first(2).map(&:first_name).join(', ')} | " \
      "evening=#{evening_ranked.first(2).map(&:first_name).join(', ')}"
    )

    @target_week.each do |date|
      fill_slots(morning_ranked, date, MORNING_START, MORNING_END)
      fill_slots(evening_ranked, date, EVENING_START, EVENING_END)
    end
  end

  private

  # ── Guard ─────────────────────────────────────────────────────────────────────

  def target_week_already_scheduled?
    week_start = @target_week.first.beginning_of_day
    week_end   = @target_week.last.end_of_day
    Meeting.filter_by_location_id(@location_id)
           .where(start_time: week_start..week_end)
           .exists?
  end

  # ── Users ────────────────────────────────────────────────────────────────────

  def active_users
    User.joins(:location_users)
        .where(location_users: { location_id: @location_id, active: true })
        .without_demo_user
  end

  # ── Worker Selection ──────────────────────────────────────────────────────────

  # Returns [morning_ranked, evening_ranked] — ALL users with historical data,
  # sorted by shift count descending. The full ranked list lets fill_slots
  # substitute backups when a top worker has a day off.
  # Returns [[], []] when no historical data exists (caller falls back to
  # round-robin using all active users).
  def determine_shift_workers(users)
    lookback_start = LOOKBACK_WEEKS.weeks.ago.beginning_of_week.beginning_of_day
    lookback_end   = @target_week.first.beginning_of_week.beginning_of_day - 1.second

    historical = Meeting.filter_by_location_id(@location_id)
                        .where(start_time: lookback_start..lookback_end)

    morning_counts = Hash.new(0)
    evening_counts = Hash.new(0)

    historical.each do |meeting|
      if meeting.morning_shift?
        morning_counts[meeting.user_id] += 1
      elsif meeting.evening_shift?
        evening_counts[meeting.user_id] += 1
      end
    end

    return [[], []] if morning_counts.empty? && evening_counts.empty?

    user_map       = users.each_with_object({}) { |u, h| h[u.id] = u }
    morning_ranked = morning_counts.sort_by { |_, n| -n }.filter_map { |id, _| user_map[id] }
    evening_ranked = evening_counts.sort_by { |_, n| -n }.filter_map { |id, _| user_map[id] }

    [morning_ranked, evening_ranked]
  end

  # ── Slot Filling ──────────────────────────────────────────────────────────────

  # Walks the ranked list and schedules workers until SLOTS_PER_SHIFT slots are
  # filled for the given day. Workers with a day-off conflict are skipped and
  # the next-ranked worker takes their place.
  def fill_slots(ranked_workers, date, hour_start, hour_end)
    filled = 0
    ranked_workers.each do |user|
      break if filled >= SLOTS_PER_SHIFT
      filled += 1 if schedule(user, date, hour_start, hour_end)
    end
  end

  # ── Shift Creation ────────────────────────────────────────────────────────────

  def schedule(user, date, hour_start, hour_end)
    start_t = date.in_time_zone(TZ).change(hour: hour_start)
    end_t   = date.in_time_zone(TZ).change(hour: hour_end)
    create_if_available(user, start_t, end_t, date)
  end

  # Returns true  — shift created or already exists (slot is covered).
  # Returns false — user has a conflicting day off; caller tries next in rank.
  def create_if_available(user, start_t, end_t, date)
    return false unless user.can_work_for_time_frame?(start_t, end_t, date)
    return true if Meeting.filter_by_location_id(@location_id)
                          .where(user_id: user.id, start_time: start_t, end_time: end_t)
                          .exists?

    Meeting.create!(start_time: start_t, end_time: end_t, user_id: user.id, location_id: @location_id)
    true
  end
end
