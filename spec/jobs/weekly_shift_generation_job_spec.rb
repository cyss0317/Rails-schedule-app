# frozen_string_literal: true

require 'rails_helper'

# Tests for WeeklyShiftGenerationJob and ShiftGenerationService.
#
# Dummy data setup:
#   - A location with 1–4 active users (via location_users :active trait)
#   - Historical meetings at exact 9AM–3PM CST (morning) or 3PM–9PM CST (evening)
#     across the 4-week lookback window so the worker-ranking logic has data.
#
# Expected output per run:
#   • Exactly 2 morning shifts + 2 evening shifts per day (28 total for 7 days)
#   • Workers are picked by total shift count — the top 2 morning workers and
#     top 2 evening workers from the last 4 weeks are scheduled for ALL 7 days.
RSpec.describe WeeklyShiftGenerationJob, type: :job do
  let(:tz)      { 'America/Chicago' }
  let(:location) { create(:location) }

  # ── Helpers ────────────────────────────────────────────────────────────────

  def create_active_user(attrs = {})
    user = create(:user, **attrs)
    create(:location_user, :active, user:, location:)
    user
  end

  # 9 AM–3 PM CST — satisfies Meeting#morning_shift?
  def morning_meeting(user, date)
    start_t = date.in_time_zone(tz).change(hour: 9)
    end_t   = date.in_time_zone(tz).change(hour: 15)
    create(:meeting, user:, location:, start_time: start_t, end_time: end_t)
  end

  # 3 PM–9 PM CST — satisfies Meeting#evening_shift?
  def evening_meeting(user, date)
    start_t = date.in_time_zone(tz).change(hour: 15)
    end_t   = date.in_time_zone(tz).change(hour: 21)
    create(:meeting, user:, location:, start_time: start_t, end_time: end_t)
  end

  # Seed a full week of morning shifts for a user (Mon–Sun, starting from monday)
  def seed_morning_week(user, monday)
    (0..6).each { |offset| morning_meeting(user, monday + offset) }
  end

  # Seed a full week of evening shifts for a user (Mon–Sun, starting from monday)
  def seed_evening_week(user, monday)
    (0..6).each { |offset| evening_meeting(user, monday + offset) }
  end

  # Mirrors the job's formula exactly: beginning_of_week + 7 always gives the
  # Monday of next week regardless of the current weekday.
  let(:next_monday) { Date.today.beginning_of_week + 7.days }
  let(:target_week) { (0..6).map { |i| next_monday + i } }

  # ── Job layer ───────────────────────────────────────────────────────────────

  describe '#perform' do
    it 'runs without error' do
      create_active_user
      expect { described_class.perform_now(location.id) }.not_to raise_error
    end

    it 'delegates to ShiftGenerationService with the correct location and upcoming week' do
      create_active_user
      expect(ShiftGenerationService).to receive(:new)
        .with(location.id, array_including(next_monday))
        .and_call_original
      described_class.perform_now(location.id)
    end

    it 'processes every location when called with no argument' do
      location2 = create(:location)
      create_active_user
      create(:user).tap { |u| create(:location_user, :active, user: u, location: location2) }

      expect(ShiftGenerationService).to receive(:new)
        .with(location.id, array_including(next_monday))
        .and_call_original
      expect(ShiftGenerationService).to receive(:new)
        .with(location2.id, array_including(next_monday))
        .and_call_original

      described_class.perform_now
    end
  end

  # ── Default round-robin (no historical data) ───────────────────────────────

  describe 'default round-robin (no historical data)' do
    it 'creates 28 shifts total — 2 morning + 2 evening × 7 days' do
      4.times { create_active_user }
      expect {
        ShiftGenerationService.new(location.id, target_week).call
      }.to change(Meeting, :count).by(28)
    end

    it 'creates only valid morning (9AM–3PM) and evening (3PM–9PM) CST shifts' do
      4.times { create_active_user }
      ShiftGenerationService.new(location.id, target_week).call
      Meeting.where(location:).find_each do |m|
        expect(m.morning_shift? || m.evening_shift?).to be true
      end
    end
  end

  # ── Pattern-based scheduling ────────────────────────────────────────────────

  describe 'pattern-based scheduling (with historical data)' do
    context 'when 2 users have a morning history' do
      it 'schedules them for morning shifts on every day of the target week' do
        alice = create_active_user(first_name: 'Alice')
        bob   = create_active_user(first_name: 'Bob')

        4.times { |i| seed_morning_week(alice, next_monday - (i + 1).weeks) }
        4.times { |i| seed_morning_week(bob,   next_monday - (i + 1).weeks) }

        ShiftGenerationService.new(location.id, target_week).call

        target_week.each do |date|
          expect(Meeting.where(user: alice, location:,
                               start_time: date.in_time_zone(tz).change(hour: 9))).to exist
          expect(Meeting.where(user: bob, location:,
                               start_time: date.in_time_zone(tz).change(hour: 9))).to exist
        end
      end
    end

    context 'when 2 users have an evening history' do
      it 'schedules them for evening shifts on every day of the target week' do
        carol = create_active_user(first_name: 'Carol')
        dave  = create_active_user(first_name: 'Dave')

        4.times { |i| seed_evening_week(carol, next_monday - (i + 1).weeks) }
        4.times { |i| seed_evening_week(dave,  next_monday - (i + 1).weeks) }

        ShiftGenerationService.new(location.id, target_week).call

        target_week.each do |date|
          expect(Meeting.where(user: carol, location:,
                               start_time: date.in_time_zone(tz).change(hour: 15))).to exist
          expect(Meeting.where(user: dave, location:,
                               start_time: date.in_time_zone(tz).change(hour: 15))).to exist
        end
      end
    end

    context 'with all 4 workers having history' do
      it 'creates exactly 28 shifts — 2 morning + 2 evening per day' do
        alice = create_active_user(first_name: 'Alice')
        bob   = create_active_user(first_name: 'Bob')
        carol = create_active_user(first_name: 'Carol')
        dave  = create_active_user(first_name: 'Dave')

        4.times do |i|
          past_monday = next_monday - (i + 1).weeks
          seed_morning_week(alice, past_monday)
          seed_morning_week(bob,   past_monday)
          seed_evening_week(carol, past_monday)
          seed_evening_week(dave,  past_monday)
        end

        expect {
          ShiftGenerationService.new(location.id, target_week).call
        }.to change(Meeting, :count).by(28)
      end
    end
  end

  # ── Worker selection by count ───────────────────────────────────────────────

  describe 'worker selection' do
    it 'picks the top 2 morning workers by total shift count; 3rd is excluded' do
      alice = create_active_user(first_name: 'Alice')  # 28 morning shifts (4 full weeks)
      bob   = create_active_user(first_name: 'Bob')    # 28 morning shifts (4 full weeks)
      carol = create_active_user(first_name: 'Carol')  # 1 morning shift (lowest count)

      4.times { |i| seed_morning_week(alice, next_monday - (i + 1).weeks) }
      4.times { |i| seed_morning_week(bob,   next_monday - (i + 1).weeks) }
      morning_meeting(carol, next_monday - 1.week)  # only 1 occurrence

      ShiftGenerationService.new(location.id, target_week).call

      # Alice and Bob (top 2) are scheduled for the whole week
      expect(Meeting.where(user: alice, location:,
                           start_time: next_monday.in_time_zone(tz).change(hour: 9))).to exist
      expect(Meeting.where(user: bob, location:,
                           start_time: next_monday.in_time_zone(tz).change(hour: 9))).to exist

      # Carol (3rd by count) gets no morning shifts
      target_week.each do |date|
        expect(Meeting.where(user: carol, location:,
                             start_time: date.in_time_zone(tz).change(hour: 9))).not_to exist
      end
    end

    it 'picks the top 2 evening workers by total shift count; 3rd is excluded' do
      carol = create_active_user(first_name: 'Carol')  # 28 evening shifts
      dave  = create_active_user(first_name: 'Dave')   # 28 evening shifts
      eve   = create_active_user(first_name: 'Eve')    # 1 evening shift

      4.times { |i| seed_evening_week(carol, next_monday - (i + 1).weeks) }
      4.times { |i| seed_evening_week(dave,  next_monday - (i + 1).weeks) }
      evening_meeting(eve, next_monday - 1.week)

      ShiftGenerationService.new(location.id, target_week).call

      expect(Meeting.where(user: carol, location:,
                           start_time: next_monday.in_time_zone(tz).change(hour: 15))).to exist
      expect(Meeting.where(user: dave, location:,
                           start_time: next_monday.in_time_zone(tz).change(hour: 15))).to exist

      target_week.each do |date|
        expect(Meeting.where(user: eve, location:,
                             start_time: date.in_time_zone(tz).change(hour: 15))).not_to exist
      end
    end
  end

  # ── Already-scheduled guard ─────────────────────────────────────────────────

  describe 'already-scheduled guard' do
    it 'skips generation when the target week already has any shifts' do
      create_active_user
      # Pre-populate one shift in the target week
      create(:meeting, location:,
             start_time: next_monday.in_time_zone(tz).change(hour: 9),
             end_time:   next_monday.in_time_zone(tz).change(hour: 15))

      expect {
        ShiftGenerationService.new(location.id, target_week).call
      }.not_to change(Meeting, :count)
    end
  end

  # ── Day-off conflict ────────────────────────────────────────────────────────

  describe 'day-off conflict' do
    it 'skips a shift on the day off but still schedules other days' do
      alice = create_active_user(first_name: 'Alice')
      bob   = create_active_user(first_name: 'Bob')

      4.times do |i|
        past_monday = next_monday - (i + 1).weeks
        seed_morning_week(alice, past_monday)
        seed_morning_week(bob,   past_monday)
      end

      # Alice has a day off on next Monday only
      create(:day_off, user: alice, location:,
             start_time: next_monday.in_time_zone(tz).beginning_of_day,
             end_time:   next_monday.in_time_zone(tz).end_of_day)

      ShiftGenerationService.new(location.id, target_week).call

      # Monday morning is skipped for Alice
      expect(Meeting.where(user: alice, location:,
                           start_time: next_monday.in_time_zone(tz).change(hour: 9))).not_to exist
      # Alice still gets morning shifts on other days (e.g. Tuesday)
      expect(Meeting.where(user: alice, location:,
                           start_time: (next_monday + 1.day).in_time_zone(tz).change(hour: 9))).to exist
    end

    it 'substitutes the next-ranked worker when a primary worker has a day off' do
      alice = create_active_user(first_name: 'Alice')  # rank 1 morning — 28 shifts
      bob   = create_active_user(first_name: 'Bob')    # rank 2 morning — 28 shifts
      carol = create_active_user(first_name: 'Carol')  # rank 3 morning — 14 shifts (backup)

      4.times { |i| seed_morning_week(alice, next_monday - (i + 1).weeks) }
      4.times { |i| seed_morning_week(bob,   next_monday - (i + 1).weeks) }
      2.times { |i| seed_morning_week(carol, next_monday - (i + 1).weeks) }

      # Bob has a day off on next Monday — Carol should fill in
      create(:day_off, user: bob, location:,
             start_time: next_monday.in_time_zone(tz).beginning_of_day,
             end_time:   next_monday.in_time_zone(tz).end_of_day)

      ShiftGenerationService.new(location.id, target_week).call

      # Monday: Alice + Carol (Carol substitutes for Bob)
      expect(Meeting.where(user: alice, location:,
                           start_time: next_monday.in_time_zone(tz).change(hour: 9))).to exist
      expect(Meeting.where(user: carol, location:,
                           start_time: next_monday.in_time_zone(tz).change(hour: 9))).to exist
      # Bob is absent on Monday
      expect(Meeting.where(user: bob, location:,
                           start_time: next_monday.in_time_zone(tz).change(hour: 9))).not_to exist

      # Bob is back on other days (e.g. Tuesday)
      expect(Meeting.where(user: bob, location:,
                           start_time: (next_monday + 1).in_time_zone(tz).change(hour: 9))).to exist
      # Carol does NOT appear on other days (only covers the gap)
      expect(Meeting.where(user: carol, location:,
                           start_time: (next_monday + 1).in_time_zone(tz).change(hour: 9))).not_to exist
    end
  end

  # ── Duplicate prevention ────────────────────────────────────────────────────

  describe 'duplicate prevention' do
    it 'does not create extra meetings when the service is called twice' do
      create_active_user
      ShiftGenerationService.new(location.id, target_week).call
      count = Meeting.count
      ShiftGenerationService.new(location.id, target_week).call
      expect(Meeting.count).to eq(count)
    end
  end
end
