require 'rails_helper'

RSpec.describe Meeting, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
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

    it '#user_name' do
      expect(meeting.user_name).to eq('Yun Sung Choi')
    end

    it '#user_name_month' do
      expect(meeting.user_name_month).to eq('Yun Choi')
    end

    it '#shift_belongs_to_hour?' do
      meeting = create(:meeting, user_id: user.id, start_time: Time.zone.parse('2023-01-01 10:00:00'), end_time: Time.zone.parse('2023-01-01 13:00:00'))

      expect(meeting.shift_belongs_to_hour?(9)).to eq(false)
      expect(meeting.shift_belongs_to_hour?(10)).to eq(true)
      expect(meeting.shift_belongs_to_hour?(11)).to eq(true)
      expect(meeting.shift_belongs_to_hour?(12)).to eq(true)
      expect(meeting.shift_belongs_to_hour?(13)).to eq(true)
      expect(meeting.shift_belongs_to_hour?(14)).to eq(false)
      expect(meeting.shift_belongs_to_hour?(15)).to eq(false)
    end
  end
end
