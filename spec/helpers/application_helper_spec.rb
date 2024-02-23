require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#morning_shifts' do
    it 'takes sorted meetings and returns morning shifts' do
      create_list(:meeting, 5, :morning_shift)
      create_list(:meeting, 5, :dinner_shift)

      morning_shifts = Meeting.all.morning_shifts
      expect(morning_shifts.count).to eq(5)
    end
  end
end
