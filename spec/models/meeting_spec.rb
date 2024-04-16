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
  end
end
