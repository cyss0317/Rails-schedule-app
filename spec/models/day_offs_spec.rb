require 'rails_helper'

RSpec.describe DayOff, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe '#off_dates' do
    it 'returns the off dates' do
      user = create(:user)
      day_off = create(:day_off, start_time: DateTime.now, end_time: DateTime.now + 3.days, user_id: user.id)

      expect(day_off.off_dates).to eq([DateTime.new("Mon, 01 Apr 2024"), DateTime.new("Mon, 02 Apr 2024"),DateTime.new("Thu, 03 Apr 2024"), DateTime.new("Thu, 04 Apr 2024")])
    end
  end
end
