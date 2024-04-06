# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DayOff, type: :model do
  let(:user) { create(:user) }
  describe 'scopes' do
    let(:day_off1) do
      create(:day_off, start_time: Date.new(2024, 1, 1), end_time: Date.new(2024, 1, 2), user_id: user.id)
    end
    let(:day_off2) do
      create(:day_off, start_time: Date.new(2024, 1, 3), end_time: Date.new(2024, 1, 3), user_id: user.id)
    end
    let(:day_off3) do
      create(:day_off, start_time: Date.new(2024, 1, 4), end_time: Date.new(2024, 1, 4), user_id: user.id)
    end
    before do
      create(:day_off, start_time: Date.new(2024, 1, 8), end_time: Date.new(2024, 1, 10), user_id: user.id)
    end
    describe '.for_day' do
      it 'takes a date and returns all the days off for that date' do
        expect(DayOff.for_day(Date.new(2024, 1, 3))).to eq([day_off2])
      end
    end
    describe '.for_week' do
      it 'returns all the days off for the given week' do
        expect(DayOff.for_week(Date.new(2024, 1, 1))).to eq([day_off1, day_off2, day_off3])
      end
    end
  end

  describe '#available_days' do
    it 'returns the available days if the days are not taken by other users' do
      create(:day_off, start_time: Date.new(2024, 1, 1), end_time: Date.new(2024, 1, 2), user_id: user.id)
      create(:day_off, start_time: Date.new(2024, 1, 3), end_time: Date.new(2024, 1, 3), user_id: user.id)
      create(:day_off, start_time: Date.new(2024, 1, 4), end_time: Date.new(2024, 1, 4), user_id: user.id)

      day_off = DayOff.new(start_time: Date.new(2024, 1, 3), end_time: Date.new(2024, 1, 6), user_id: user.id)

      expect(day_off.available_days).to eq([Date.new(2024, 1, 5), Date.new(2024, 1, 6)])
    end
  end
  describe '#off_dates' do
    it 'returns the off dates' do
      user = create(:user)
      day_off = create(:day_off, start_time: Date.new(2024, 1, 1), end_time: Date.new(2024, 1, 4), user_id: user.id)

      expect(day_off.off_dates).to eq([Date.new(2024, 1, 1), Date.new(2024, 1, 2), Date.new(2024, 1, 3),
                                       Date.new(2024, 1, 4)])
    end
  end

  describe '#taken_days' do
    it 'returns the taken days if some days are already taken from other user' do
      user = create(:user)
      create(:day_off, start_time: Date.new(2024, 1, 7), end_time: Date.new(2024, 1, 7), user_id: user.id)
      create(:day_off, start_time: Date.new(2024, 1, 1),
                       end_time: Date.new(2024, 1, 1) + 3.days, user_id: user.id)
      day_off = DayOff.new(start_time: Date.new(2024, 1, 1),
                           end_time: Date.new(2024, 1, 8), user_id: user.id)

      expect(day_off.taken_days).to eq([Date.new(2024, 1, 1), Date.new(2024, 1, 2), Date.new(2024, 1, 3),
                                        Date.new(2024, 1, 4), Date.new(2024, 1, 7)])
    end
  end

  describe '#validations' do
    let(:user) { create(:user) }
    before do
      create(
        :day_off,
        start_time: Date.new(2024, 1, 7),
        end_time: Date.new(2024, 1, 7),
        user_id: user.id
      )
      create(
        :day_off,
        start_time: Date.new(2024, 1, 1),
        end_time: Date.new(2024, 1, 4),
        user_id: user.id
      )
    end
    describe 'any_of_days_taken?' do
      it 'returns true if any of the days are taken' do
        day_off = DayOff.new(
          start_time: Date.new(2024, 1, 1),
          end_time: Date.new(2024, 1, 8),
          user_id: user.id
        )

        expect(day_off.any_of_days_taken?).to eq(true)
      end

      it 'returns false if none of the days are taken' do
        day_off = create(
          :day_off,
          start_time: Date.new(2024, 1, 9),
          end_time: Date.new(2024, 1, 10),
          user_id: user.id
        )

        expect(day_off.any_of_days_taken?).to eq(false)
      end
    end

    describe '#check_days_taken' do
      it 'creates DayOff instance when no days are taken' do
        day_off = DayOff.new(
          start_time: Date.new(2024, 1, 9),
          end_time: Date.new(2024, 1, 10),
          user_id: user.id
        )

        expect do
          day_off.save
        end.to change(DayOff, :count).by(1)
      end

      it 'adds an error message if any of the days are taken' do
        day_off = DayOff.new(
          start_time: Date.new(2024, 1, 2),
          end_time: Date.new(2024, 1, 3),
          user_id: user.id
        )

        day_off.save

        expect(day_off.errors.full_messages).to include('These days are taken by others 2024-01-02, 2024-01-03')
      end
    end
  end
end
