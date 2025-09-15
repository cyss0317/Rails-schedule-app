# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:location) { create(:location) }
  before do
    create_list(:meeting, 4, :morning_shift, location_id: location.id)
    create_list(:meeting, 5, :dinner_shift, location_id: location.id)
  end
  describe '#morning_shifts' do
    it 'takes sorted meetings and returns morning shifts' do
      morning_shifts = morning_shifts(Meeting.filter_by_location_id(location.id).all)

      expect(morning_shifts.count).to eq(4)
    end
  end

  describe '#dinner_shifts' do
    it 'takes meetings and retrurns dinner shifts' do
      dinner_shifts = dinner_shifts(Meeting.all)

      expect(dinner_shifts.count).to eq(5)
    end
  end
end
