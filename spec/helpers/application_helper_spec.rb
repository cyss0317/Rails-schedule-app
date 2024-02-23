require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#morning_shifts' do
    it 'takes sorted meetings and returns morning shifts' do
      create_list(:meeting, 10)

      expect(Meeting.count).to eq(10)
    end
  end
end
