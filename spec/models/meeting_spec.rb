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
    it 'find_all_by_user_id' do
      create_list(:meeting, 3, user_id: user.id)

      expect(Meeting.find_all_by_user_id(user.id).count).to eq(3)
    end

    it 'sort_by_start_time' do
      create(:meeting, user_id: user.id, start_time: Time.zone.parse('2023-01-01 10:00:00'))
      create(:meeting, user_id: user.id, start_time: Time.zone.parse('2023-01-01 11:00:00'))
      create(:meeting, user_id: user.id, start_time: Time.zone.parse('2023-01-01 12:00:00'))
``
      sorted_meetings = Meeting.sort_by_start_time

      expect(sorted_meetings[0].start_time.hour).to eq(10)
      expect(sorted_meetings[1].start_time.hour).to eq(11)
      expect(sorted_meetings[2].start_time.hour).to eq(12)

    end
  end
end
