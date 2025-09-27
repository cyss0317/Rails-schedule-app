# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DayOff, type: :model do
  let(:user) { create(:user) }
  let(:location) { create(:location) }

  describe 'scopes' do
    let(:day_off1) do
      create(:day_off, start_time: Time.new(2024, 1, 1), end_time: Time.new(2024, 1, 2).end_of_day, user_id: user.id,
                       location_id: location.id)
    end
    let(:day_off2) do
      create(:day_off, start_time: Time.new(2024, 1, 3), end_time: Time.new(2024, 1, 3).end_of_day, user_id: user.id,
                       location_id: location.id)
    end
    let(:day_off3) do
      create(:day_off, start_time: Time.new(2024, 1, 4), end_time: Time.new(2024, 1, 4).end_of_day, user_id: user.id,
                       location_id: location.id)
    end
    before do
      create(:day_off, start_time: Time.new(2024, 1, 8), end_time: Time.new(2024, 1, 10).end_of_day, user_id: user.id,
                       location_id: location.id)
    end
    describe '.for_day_filtered_by_date' do
      it 'takes a date and returns all the days off for that date' do
        day_off5 = create(:day_off, start_time: Time.new(2024, 1, 3), end_time: Time.new(2024, 1, 3).end_of_day.change(sec: 0),
                                    user_id: user.id)
        day_off6 = create(:day_off, start_time: Time.new(2024, 1, 5, 14), end_time: Time.new(2024, 1, 5).end_of_day.change(sec: 0),
                                    user_id: user.id)

        expect(DayOff.for_day_filtered_by_date(Time.new(2024, 1, 8))).to eq([DayOff.first])
        expect(DayOff.for_day_filtered_by_date(Time.new(2024, 1, 9))).to eq([DayOff.first])
        expect(DayOff.for_day_filtered_by_date(Time.new(2024, 1, 3))).to eq([day_off5])
        expect(DayOff.for_day_filtered_by_date(Time.new(2024, 1, 5))).to eq([day_off6])
        expect(DayOff.for_day_filtered_by_date(Time.new(2024, 1, 6))).to eq([])
      end
    end

    describe '.morning_day_offs' do
      it 'returns day off for morning for certain date' do
        create(:day_off, start_time: Time.new(2024, 1, 1, 15), end_time: Time.new(2024, 1, 1).end_of_day,
                         user_id: user.id)
        morning_day_off = create(:day_off, start_time: Time.new(2024, 1, 2, 8), end_time: Time.new(2024, 1, 2, 15),
                                           user_id: user.id)

        expect(DayOff.morning_day_offs(Time.new(2024, 1, 8))).to eq([])
        expect(DayOff.morning_day_offs(Time.new(2024, 1, 1))).to eq([])
        expect(DayOff.morning_day_offs(Time.new(2024, 1, 2))).to eq([morning_day_off])
      end
    end

    describe '.evening_day_offs' do
      it 'ONLY returns day off for evening for certain date' do
        evening_day_off = create(:day_off, start_time: Time.new(2024, 1, 1, 15), end_time: Time.new(2024, 1, 1).end_of_day.change(sec: 0),
                                           user_id: user.id)
        create(:day_off, start_time: Time.new(2024, 1, 1, 8), end_time: Time.new(2024, 1, 1, 15))

        expect(DayOff.evening_day_offs(Time.new(2024, 1, 8))).to eq([])
        expect(DayOff.evening_day_offs(Time.new(2024, 1, 1))).to eq([evening_day_off])
      end
    end

    describe '.for_week' do
      it 'returns all the days off for the given week' do
        expect(DayOff.for_week(DateTime.new(2024, 1, 1))).to eq([day_off1, day_off2, day_off3])
      end
    end

    describe '.filter_by_location_id(location_id)' do
      it 'only returns day offs belong to given location' do
        create_list(:day_off, 4, location_id: location.id)
        expect(DayOff.filter_by_location_id(location.id).count).to eq(5)
      end
    end
  end

  describe '.for_day_filter_by_datetime' do
    it 'takes in start_time and end_time and returns the day off for that time' do
      day_off = create(:day_off, start_time: Time.new(2024, 1, 1, 8), end_time: Time.new(2024, 1, 1, 15),
                                 user_id: user.id)

      expect(DayOff.for_day_filtered_by_datetime(day_off.start_time, day_off.end_time)).to eq([day_off])
    end
    it 'takes in start_time and end_time and returns empty if none exists' do
      day_off = create(:day_off, start_time: Time.new(2024, 1, 1, 8), end_time: Time.new(2024, 1, 1, 15),
                                 user_id: user.id)

      expect(DayOff.for_day_filtered_by_datetime(day_off.start_time, day_off.end_time)).to eq([day_off])
    end
  end
  describe '#off_time_info' do
    it 'returns the off time for morning off' do
      day_off = create(:day_off, start_time: Time.new(2024, 1, 1, 10), end_time: Time.new(2024, 1, 1, 15),
                                 user_id: user.id)

      expect(day_off.off_time_info(Time.new(2024, 1, 1))).to eq("#{user.first_name}, Morning Off")
    end
    it 'returns the off time for evening off' do
      day_off = create(:day_off, start_time: Time.new(2024, 1, 1, 15), end_time: Time.new(2024, 1, 1, 17),
                                 user_id: user.id)

      expect(day_off.off_time_info(Time.new(2024, 1, 1))).to eq("#{user.first_name}, Evening Off")
    end
    it 'returns the off time for all day off' do
      day_off = create(:day_off, start_time: Time.new(2024, 1, 1), end_time: Time.new(2024, 1, 1).end_of_day,
                                 user_id: user.id, location_id: location.id)

      expect(day_off.off_time_info(Time.new(2024, 1, 1))).to eq("#{user.first_name}, All Day Off")
    end
  end
  describe '#available_days' do
    it 'returns the available days if the days are not taken by other users' do
      create(:day_off, start_time: Time.new(2024, 1, 1), end_time: Time.new(2024, 1, 1).end_of_day, user_id: user.id,
                       location_id: location.id)
      create(:day_off, start_time: Time.new(2024, 1, 3), end_time: Time.new(2024, 1, 3).end_of_day, user_id: user.id,
                       location_id: location.id)
      create(:day_off, start_time: Time.new(2024, 1, 4), end_time: Time.new(2024, 1, 4).end_of_day, user_id: user.id,
                       location_id: location.id)
      create(:day_off, start_time: Time.new(2024, 1, 5, 0), end_time: Time.new(2024, 1, 5, 15),
                       user_id: user.id,           location_id: location.id)
      create(:day_off, start_time: Time.new(2024, 1, 6, 15), end_time: Time.new(2024, 1, 6).end_of_day,
                       user_id: user.id,           location_id: location.id)

      day_off = DayOff.new(start_time: Time.new(2024, 1, 1), end_time: Time.new(2024, 1, 6), user_id: user.id,
                           location_id: location.id)

      expect(day_off.available_days).to eq(['2024-01-02 All Day', '2024-01-05 3PM - 9PM', '2024-01-06 8AM - 3PM'])
    end

    it 'returns the available evening off time frame if morning off is taken already' do
      create(:day_off, start_time: Time.new(2024, 1, 1), end_time: Time.new(2024, 1, 1, 15), user_id: user.id, location_id: location.id)

      day_off = DayOff.new(start_time: Time.new(2024, 1, 1, 15), end_time: Time.new(2024, 1, 1).end_of_day,
                           user_id: user.id, location_id: location.id)
      expect(day_off.available_days).to eq(['2024-01-01 3PM - 9PM'])
    end
  end
  describe '#off_dates' do
    it 'returns the off dates' do
      user = create(:user)
      day_off = create(:day_off, start_time: Time.new(2024, 1, 1), end_time: Time.new(2024, 1, 4).end_of_day,
                                 user_id: user.id)

      expect(day_off.off_dates).to eq([Date.new(2024, 1, 1), Date.new(2024, 1, 2), Date.new(2024, 1, 3),
                                       Date.new(2024, 1, 4)])
    end
  end

  describe '#half_day_taken?' do
    it 'takes in date and returns true if the day is half day off' do
      morning_off = create(:day_off, start_time: Time.new(2024, 1, 1, 8),
                                     end_time: Time.new(2024, 1, 1, 15).end_of_day, user_id: user.id)

      morning_off.half_day_taken?(Time.new(2024, 1, 1))
    end
    it 'takes in date and returns false if the day is all day off' do
      morning_off = create(:day_off, start_time: Time.new(2024, 1, 1), end_time: Time.new(2024, 1, 1), user_id: user.id)

      morning_off.half_day_taken?(Time.new(2024, 1, 1))
    end
  end
  describe '#taken_days' do
    it 'returns the taken days if some days are already taken from other user' do
      user = create(:user)

      create(:day_off, start_time: Date.new(2024, 1, 1), end_time: Date.new(2024, 1, 4), user_id: user.id)
      create(:day_off, start_time: Date.new(2024, 1, 7), end_time: Date.new(2024, 1, 7), user_id: user.id)

      day_off = DayOff.new(start_time: Date.new(2024, 1, 1), end_time: Date.new(2024, 1, 8), user_id: user.id)

      expect(day_off.taken_days).to eq([Date.new(2024, 1, 1), Date.new(2024, 1, 2), Date.new(2024, 1, 3),
                                        Date.new(2024, 1, 4), Date.new(2024, 1, 7)])
    end
  end

  describe '#morning_off?' do
    it 'returns true if the day is morning off' do
      morning_off = create(:day_off, start_time: Time.new(2024, 1, 1, 8), end_time: Time.new(2024, 1, 1, 15),
                                     user_id: user.id)

      expect(morning_off.morning_off?(Time.new(2024, 1, 1))).to eq(true)
    end
    it 'returns false if the day is NOT morning off' do
      evening_off = create(:day_off, start_time: Time.new(2024, 1, 1, 15), end_time: Time.new(2024, 1, 1, 17),
                                     user_id: user.id)

      expect(evening_off.morning_off?(Time.new(2024, 1, 1))).to eq(false)
    end
  end

  describe '#evening_off?' do
    it 'returns true if the day is evening off' do
      evening_off = create(:day_off, start_time: Time.new(2024, 1, 1, 15), end_time: Time.new(2024, 1, 1, 17))

      expect(evening_off.evening_off?(Time.new(2024, 1, 1))).to eq(true)
    end

    it 'returns false if the day is NOT evening off' do
      morning_off = create(:day_off, start_time: Time.new(2024, 1, 1, 8), end_time: Time.new(2024, 1, 1, 15))

      expect(morning_off.evening_off?(Time.new(2024, 1, 1))).to eq(false)
    end
  end

  describe '#all_day_off?' do
    it 'returns true if the day is all day off' do
      all_day_off = create(:day_off, start_time: Time.new(2024, 1, 1), end_time: Time.new(2024, 1, 1).end_of_day)

      expect(all_day_off.all_day_off?(Time.new(2024, 1, 1))).to eq(true)
    end

    it 'returns false if the day is NOT all day off' do
      morning_off = create(:day_off, start_time: Time.new(2024, 1, 1, 8), end_time: Time.new(2024, 1, 1, 15))
      evening_off = create(:day_off, start_time: Time.new(2024, 1, 1, 15), end_time: Time.new(2024, 1, 1).end_of_day)

      expect(morning_off.all_day_off?(Time.new(2024, 1, 1))).to eq(false)
      expect(evening_off.all_day_off?(Time.new(2024, 1, 1))).to eq(false)
    end
  end

  describe '#validations' do
    let(:user) { create(:user) }
    before do
      create(
        :day_off,
        start_time: Time.new(2024, 1, 1),
        end_time: Time.new(2024, 1, 10).end_of_day,
        user_id: user.id,
        location_id: location.id
      )
    end
    describe 'any_of_days_taken?' do
      it 'returns true if any of the days are taken' do
        day_off = DayOff.new(
          start_time: Time.new(2024, 1, 1),
          end_time: Time.new(2024, 1, 8),
          user_id: user.id
        )
        expect(day_off.any_of_days_taken?).to eq(true)
      end

      it 'returns false if none of the days are taken' do
        day_off = DayOff.new(
          start_time: Time.new(2024, 1, 11),
          end_time: Time.new(2024, 1, 12),
          user_id: user.id
        )

        expect(day_off.any_of_days_taken?).to eq(false)
      end

      it 'fails to create a dayOff if description is not given' do
        expect do
          DayOff.create(
            start_time: Time.new(2024, 1, 11),
            end_time: Time.new(2024, 1, 12),
            user_id: user.id,
            location_id: location.id
          )
        end.to change(DayOff, :count).by(0)
      end
    end

    describe '#check_days_taken' do
      it 'creates DayOff instance when no days are taken' do
        day_off = DayOff.new(
          start_time: Time.new(2024, 1, 11),
          end_time: Time.new(2024, 1, 12).end_of_day,
          user_id: user.id,
          description: "I'm taking a day off",
          location_id: location.id
        )

        expect do
          day_off.save
        end.to change(DayOff, :count).by(1)
      end

      it 'adds "All Dates are already taken" error message if all days are taken' do
        day_off = DayOff.new(
          start_time: Time.new(2024, 1, 1),
          end_time: Time.new(2024, 1, 7),
          user_id: user.id,
          description: "I'm taking a week off",
          location_id: location.id
        )

        day_off.save

        expect(day_off.errors.full_messages).to include('All dates are already taken')
      end

      it 'adds available dates and times to error message if all days are taken' do
        day_off = DayOff.new(
          start_time: Time.new(2024, 1, 7),
          end_time: Time.new(2024, 1, 11).end_of_day,
          user_id: user.id,
          location_id: location.id
        )

        day_off.save

        expect(day_off.errors.full_messages).to include('Available dates are [2024-01-11 All Day]. Sorry, other day(s) is/are taken.')
      end
      it 'does NOT add any errors if there is no DayOff object within the time frame' do
        create(:day_off, start_time: Time.new(2024, 1, 1), end_time: Time.new(2024, 1, 1, 15), user_id: user.id)
        day_off = DayOff.new(
          start_time: Time.new(2024, 1, 1, 15),
          end_time: Time.new(2024, 1, 1).end_of_day,
          user_id: user.id,
          description: "I'm taking a day off",
          location_id: location.id
        )

        day_off.save

        expect(day_off.errors.full_messages).to be_empty
      end
    end

    describe '#been_passed?' do
      it 'returns true if the day off has already passed' do
        day_off = DayOff.new(
          start_time: Time.new(2024, 1, 1),
          end_time: Time.new(2024, 1, 1).end_of_day,
          user_id: user.id
        )

        expect(day_off.been_passed?).to eq(true)
      end
      it 'returns false if the day off has already passed' do
        day_off = DayOff.new(
          start_time: (Time.now + 1.day).beginning_of_day,
          end_time: (Time.now + 1.day).end_of_day,
          user_id: user.id
        )

        expect(day_off.been_passed?).to eq(false)
      end
    end
  end
end
