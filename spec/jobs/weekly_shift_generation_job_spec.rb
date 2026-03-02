# frozen_string_literal: true

require 'rails_helper'

# Tests for WeeklyShiftGenerationJob and PasteLastWeekService.
#
# PasteLastWeekService copies all meetings from the week immediately before the
# target week, preserving day-of-week mapping (Mon→Mon, Tue→Tue, etc.).
# Duplicate guard prevents re-copying if the target already has the same shift.
# Day-off conflicts are skipped and returned in the unable list.
RSpec.describe WeeklyShiftGenerationJob, type: :job do
  let(:tz)      { 'America/Chicago' }
  let(:location) { create(:location) }

  let(:next_monday) { Date.today.beginning_of_week + 7.days }
  let(:target_week) { (0..6).map { |i| next_monday + i } }
  let(:source_monday) { next_monday - 7.days }

  def create_active_user(attrs = {})
    user = create(:user, **attrs)
    create(:location_user, :active, user:, location:)
    user
  end

  # Creates a meeting in the source (previous) week at fixed UTC hours.
  def source_shift(user, date, hour_start: 9, hour_end: 15)
    start_t = date.to_time.utc.change(hour: hour_start)
    end_t   = date.to_time.utc.change(hour: hour_end)
    create(:meeting, user:, location:, start_time: start_t, end_time: end_t)
  end

  # ── Job layer ────────────────────────────────────────────────────────────────

  describe '#perform' do
    it 'runs without error' do
      create_active_user
      expect { described_class.perform_now(location.id) }.not_to raise_error
    end

    it 'delegates to PasteLastWeekService with the correct location and upcoming week' do
      create_active_user
      expect(PasteLastWeekService).to receive(:new)
        .with(location.id, array_including(next_monday))
        .and_call_original
      described_class.perform_now(location.id)
    end

    it 'processes every location when called with no argument' do
      location2 = create(:location)
      create_active_user
      create(:user).tap { |u| create(:location_user, :active, user: u, location: location2) }

      expect(PasteLastWeekService).to receive(:new)
        .with(location.id, array_including(next_monday))
        .and_call_original
      expect(PasteLastWeekService).to receive(:new)
        .with(location2.id, array_including(next_monday))
        .and_call_original

      described_class.perform_now
    end
  end

  # ── PasteLastWeekService ─────────────────────────────────────────────────────

  describe PasteLastWeekService do
    describe '#call' do
      it 'copies a shift from the previous week into the target week' do
        user = create_active_user
        source_shift(user, source_monday)

        expect do
          PasteLastWeekService.new(location.id, target_week).call
        end.to change(Meeting, :count).by(1)

        copied = Meeting.where(location:, user:).order(:start_time).last
        expect(copied.start_time.to_date).to eq(next_monday)
      end

      it 'preserves the day-of-week mapping (Wed → Wed)' do
        user = create_active_user
        source_shift(user, source_monday + 2) # Wednesday of source week

        PasteLastWeekService.new(location.id, target_week).call

        expect(Meeting.where(location:, user:).order(:start_time).last.start_time.to_date)
          .to eq(next_monday + 2)
      end

      it 'copies all seven days when all are populated in the source week' do
        user = create_active_user
        7.times { |i| source_shift(user, source_monday + i) }

        expect do
          PasteLastWeekService.new(location.id, target_week).call
        end.to change(Meeting, :count).by(7)
      end

      it 'does not create duplicates when called twice' do
        user = create_active_user
        source_shift(user, source_monday)

        PasteLastWeekService.new(location.id, target_week).call
        count = Meeting.count
        PasteLastWeekService.new(location.id, target_week).call

        expect(Meeting.count).to eq(count)
      end

      it 'returns an empty unable list when all meetings copy successfully' do
        user = create_active_user
        source_shift(user, source_monday)

        unable_list = PasteLastWeekService.new(location.id, target_week).call
        expect(unable_list).to be_empty
      end

      it 'does not create any meetings when the previous week has no shifts' do
        create_active_user

        expect do
          PasteLastWeekService.new(location.id, target_week).call
        end.not_to change(Meeting, :count)
      end

      context 'when a user has a conflicting day off in the target week' do
        it 'skips the meeting and returns it in the unable list' do
          user = create_active_user
          source_shift(user, source_monday, hour_start: 9, hour_end: 15)

          # Day off covers all of next Monday in CST
          create(:day_off, user:,      location:,
                 start_time:           next_monday.in_time_zone(tz).beginning_of_day,
                 end_time:             next_monday.in_time_zone(tz).end_of_day)

          expect do
            @unable_list = PasteLastWeekService.new(location.id, target_week).call
          end.not_to change(Meeting, :count)

          expect(@unable_list.length).to eq(1)
        end

        it 'still schedules other days without day-off conflicts' do
          user = create_active_user
          # Source: Monday AND Tuesday
          source_shift(user, source_monday)
          source_shift(user, source_monday + 1)

          # Only Monday blocked
          create(:day_off, user:,      location:,
                 start_time:           next_monday.in_time_zone(tz).beginning_of_day,
                 end_time:             next_monday.in_time_zone(tz).end_of_day)

          PasteLastWeekService.new(location.id, target_week).call

          # Tuesday copy exists
          expect(Meeting.where(location:, user:)
                        .where('start_time::date = ?', next_monday + 1)).to exist
          # Monday copy does not exist
          expect(Meeting.where(location:, user:)
                        .where('start_time::date = ?', next_monday)).not_to exist
        end
      end
    end
  end
end
