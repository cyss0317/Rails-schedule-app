require 'rails_helper'
require_relative '../config/initializers/simple_calendar_patch'

RSpec.describe 'SimpleCalendar' do
  describe '#render_shifts_by_hour' do
    it 'renders shifts by hour' do
      today = Time.zone.now
      meetings = (8..24).to_a.map do |hour|
        create(:meeting, :hour_from, start_time: Time.new(today.year, today.month, today.day, hour))
      end

      expect(SimpleCalendar::WeekCalendar.new(self).render_shifts_by_hour(meetings)).to eq(17)
    end
  end
end
