# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Meeting, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    it '.find_all_by_user_id' do
      create_list(:meeting, 3, user_id: user.id)

      expect(Meeting.find_all_by_user_id(user.id).count).to eq(3)
    end

    it '.sort_by_start_time' do
      create(:meeting, user_id: user.id, start_time: Time.zone.parse('2023-01-01 10:00:00'))
      create(:meeting, user_id: user.id, start_time: Time.zone.parse('2023-01-01 11:00:00'))
      create(:meeting, user_id: user.id, start_time: Time.zone.parse('2023-01-01 12:00:00'))

      sorted_meetings = Meeting.sort_by_start_time

      expect(sorted_meetings[0].start_time.hour).to eq(10)
      expect(sorted_meetings[1].start_time.hour).to eq(11)
      expect(sorted_meetings[2].start_time.hour).to eq(12)
    end

    it '.within_range' do
      target_date = Time.zone.parse('2023-01-02 10:00:00')
      meeting = create(:meeting, user_id: user.id, start_time: target_date)
      (1..8).each do |idx|
        create(:meeting, user_id: user.id, start_time: meeting.start_time + idx.day,
                         end_time: meeting.end_time + idx.day)
      end
      range = [target_date, target_date + 1.day, target_date + 2.days]
      expect(Meeting.within_range(range).length).to be(3)
    end
    it '.meetings_for_the_week' do
      target_date = Time.zone.parse('2023-01-02 10:00:00')
      meeting = create(:meeting, user_id: user.id, start_time: target_date)
      (1..8).each do |idx|
        create(:meeting, user_id: user.id, start_time: meeting.start_time + idx.day,
                         end_time: meeting.end_time + idx.day)
      end
      expect(Meeting.meetings_for_the_week(target_date).length).to be(7)
      expect(Meeting.meetings_for_the_week(target_date + 7.days).length).to be(2)
    end

    it '.filter_by_location_id(location_id)' do
      locations = create_list(:location, 2, :with_relationships, meetings_count: 10)
      location = create(:location, :with_relationships, meetings_count: 20)
      expect(Meeting.filter_by_location_id(locations[0].id).length).to be(10)
      expect(Meeting.filter_by_location_id(locations[0].id).length).to be(10)
      expect(Meeting.filter_by_location_id(location.id).length).to be(20)
    end
  end

  describe 'methods' do
    let(:user) { create(:user, first_name: 'Yun', middle_name: 'Sung', last_name: 'Choi') }
    let(:meeting) { create(:meeting, user_id: user.id) }

    it '#user_full_name' do
      expect(meeting.user_full_name).to eq('Yun Sung Choi')
    end

    it '#user_name' do
      expect(meeting.user_name).to eq('Yun')
    end

    it '#user_name_month' do
      expect(meeting.user_name_month).to eq('Yun Choi')
    end

    it '#shift_belongs_to_hour?' do
      meeting = create(:meeting, user_id: user.id, start_time: Time.zone.parse('2023-01-01 10:00:00'),
                                 end_time: Time.zone.parse('2023-01-01 13:00:00'))

      expect(meeting.shift_belongs_to_hour?(9)).to eq(false)
      expect(meeting.shift_belongs_to_hour?(10)).to eq(true)
      expect(meeting.shift_belongs_to_hour?(11)).to eq(true)
      expect(meeting.shift_belongs_to_hour?(12)).to eq(true)
      expect(meeting.shift_belongs_to_hour?(13)).to eq(false)
      expect(meeting.shift_belongs_to_hour?(14)).to eq(false)
      expect(meeting.shift_belongs_to_hour?(15)).to eq(false)
    end

    describe '#table_row_left_shift' do
      let(:meeting) { create(:meeting) }
      it 'returns 0 when idx is 0 and meetings_count is 4 and hour_idx is 0' do
        idx = 0
        meetings_count = 4
        hour_idx = 0

        expect(meeting.table_row_left_shift(idx, meetings_count, hour_idx)).to eq(0)
      end
      it 'returns 20 when idx is 1 and meetings_count is 4 and hour_idx is 1' do
        idx = 1
        meetings_count = 4
        hour_idx = 1

        expect(meeting.table_row_left_shift(idx, meetings_count, hour_idx)).to eq(20)
      end
      it 'returns 84 when idx is 5 and meetings_count is 4 and hour_idx is 2' do
        idx = 5
        meetings_count = 4
        hour_idx = 2

        expect(meeting.table_row_left_shift(idx, meetings_count, hour_idx)).to eq(84)
      end
      it 'returns 20 when idx is 9 and meetings_count is 4 and hour_idx is 3' do
        idx = 9
        meetings_count = 4
        hour_idx = 3

        expect(meeting.table_row_left_shift(idx, meetings_count, hour_idx)).to eq(20)
      end
    end

    describe '#shift_start_from?' do
      it 'takes a integer as hour and returns true if the start time is before the hour' do
        meeting = create(:meeting, user_id: user.id, start_time: Time.zone.parse('2023-01-01 10:00:00'),
                                   end_time: Time.zone.parse('2023-01-01 13:00:00'))

        expect(meeting.shift_start_from?(9)).to eq(false)
        expect(meeting.shift_start_from?(10)).to eq(true)
        expect(meeting.shift_start_from?(11)).to eq(false)
        expect(meeting.shift_start_from?(12)).to eq(false)
        expect(meeting.shift_start_from?(13)).to eq(false)
        expect(meeting.shift_start_from?(14)).to eq(false)
      end
    end
    # describe '#filter_by_hour' do
    #   it 'takes integer as an argument and returns an array of meetings that belong to the hour' do
    #     create(
    #       :meeting,
    #       user_id: user.id,
    #       start_time: Time.zone.parse('2023-01-01 10:00:00'),
    #       end_time: Time.zone.parse('2023-01-01 13:00:00')
    #     )
    #     create(
    #       :meeting,
    #       user_id: user.id,
    #       start_time: Time.zone.parse('2023-01-01 14:00:00'),
    #       end_time: Time.zone.parse('2023-01-01 17:00:00')
    #     )

    #     expect(Meeting.filter_by_hour(10).count).to eq(1)
    #     expect(Meeting.filter_by_hour(14).count).to eq(1)
    #   end
    # end

    describe '#user_weekly_name' do
      it 'returns first name and first letter of middle name first letter of last name ' do
        meeting = create(:meeting)

        expect(meeting.user_weekly_name).to eq("#{meeting.user[:first_name]} #{meeting.user[:middle_name][0].capitalize}. #{meeting.user[:last_name][0].capitalize}".to_s)
      end
    end

    describe '.most_recent_week_meetings' do
      it 'returns all the meetings of the most recent meeting' do
        today = Date.new(2025, 7, 14)
        7.times do |idx|
          create(:meeting, start_time: today.beginning_of_week + idx.day, end_time: today + idx.day + 2.hours)
        end

        expect(Meeting.most_recent_week_meetings.count).to be(7)

        7.times do |idx|
          create(:meeting, start_time: today.beginning_of_week + idx.day, end_time: today + idx.day + 2.hours)
        end

        expect(Meeting.most_recent_week_meetings.count).to be(14)

        9.times do |idx|
          create(:meeting, start_time: today.beginning_of_week + idx.day, end_time: today + idx.day + 2.hours)
        end

        expect(Meeting.most_recent_week_meetings.count).to be(2)
      end
    end

    describe '.copy_most_recent_week_of_meetings_to_target_week' do
      it 'copies the most recent week of meetings to target week' do
        start_date = Date.parse('2025-07-21') # Monday
        target_week = (0..6).map { |i| start_date + i }

        today = Date.new(2025, 7, 14)
        7.times do |idx|
          create(:meeting, start_time: today.beginning_of_week + idx.day, end_time: today + idx.day + 2.hours)
        end

        expect do
          Meeting.copy_most_recent_week_of_meetings_to_target_week(target_week)
        end.to change(Meeting, :count).by(7)
      end

      it "does NOT copy those meetings overlap with the user's day off" do
        start_date = Date.parse('2025-07-21') # Monday
        user.day_offs << create(:day_off, user:,
                                          start_time: DateTime.parse("#{start_date} 00:00:01"),
                                          end_time: DateTime.parse("#{start_date} 23:23:59"))
        user.save!
        target_week = (0..6).map { |i| start_date + i }

        today = Date.new(2025, 7, 14)
        7.times do |idx|
          create(:meeting, user:, start_time: today.beginning_of_week + idx.day, end_time: today + idx.day + 2.hours)
        end
        7.times do |idx|
          create(:meeting, user:, start_time: today.beginning_of_week + idx.day, end_time: today + idx.day + 2.hours)
        end

        expect do
          Meeting.copy_most_recent_week_of_meetings_to_target_week(target_week)
        end.to change(Meeting, :count).by(12)
      end
    end

    describe '#updated_date_on_start_time' do
      it 'returns a new datetime with updated date without changing the time' do
        meeting = create(:meeting, start_time: DateTime.new(2022, 11, 11, 15, 0, 0, '-05:00'),
                                   end_time: DateTime.new(2022, 11, 11, 18, 0, 0, '-05:00'))
        target_date = Date.parse('2025-08-12')

        expect(meeting.updated_date_on_start_time(target_date)).to eq(DateTime.parse("#{target_date} 15:00:00 -05:00"))
        expect(meeting.end_time).to eq(DateTime.parse("#{Date.parse('2022-11-11')} 18:00:00 -05:00"))
      end
    end

    describe '#updated_date_on_end_time' do
      it 'returns a new datetime with updated date without changing the time' do
        meeting = create(:meeting, start_time: DateTime.new(2022, 11, 11, 15, 0, 0, '-05:00'),
                                   end_time: DateTime.new(2022, 11, 11, 18, 0, 0, '-05:00'))
        target_date = Date.parse('2025-08-12')

        expect(meeting.updated_date_on_end_time(target_date)).to eq(DateTime.parse("#{target_date} 18:00:00 -05:00"))
        expect(meeting.start_time).to eq(DateTime.parse("#{Date.parse('2022-11-11')} 15:00:00 -05:00"))
      end
    end
  end
end
