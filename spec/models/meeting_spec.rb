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
    it 'find_all_by_user_id' do
      user = create(:user)

      create_list(:meeting, 3, user_id: user.id)

      expect(Meeting.find_all_by_user_id(user.id).count).to eq(3)
    end
  end
end
