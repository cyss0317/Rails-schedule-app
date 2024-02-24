require 'rails_helper'
require_relative '../config/initializers/simple_calendar_patch'

RSpec.describe 'SimpleCalendar' do
  describe '#render_shifts_by_hour' do
    it 'renders shifts by hour' do
      today = Time.zone.now
      week_calendar = SimpleCalendar::WeekCalendar.new(self)
      (8...24).to_a.map do |hour|
        create(:meeting, :hour_from, start_time: Time.new(today.year, today.month, today.day, hour))
        create(:meeting, :hour_from, start_time: Time.new(today.year, today.month, today.day, hour))
      end

      meetings_order_by_start_time = week_calendar.render_shifts_by_hour(Meeting.all)

      expect(meetings_order_by_start_time[0].count).to eq(2)
      expect(meetings_order_by_start_time[1].count).to eq(2)
      expect(meetings_order_by_start_time[2].count).to eq(2)
      expect(meetings_order_by_start_time[3].count).to eq(2)
      expect(meetings_order_by_start_time[4].count).to eq(2)
      expect(meetings_order_by_start_time[5].count).to eq(2)
      expect(meetings_order_by_start_time[6].count).to eq(2)
      expect(meetings_order_by_start_time[7].count).to eq(2)
      expect(meetings_order_by_start_time[8].count).to eq(2)
      expect(meetings_order_by_start_time[9].count).to eq(2)
      expect(meetings_order_by_start_time[10].count).to eq(2)
      expect(meetings_order_by_start_time[11].count).to eq(2)
      expect(meetings_order_by_start_time[12].count).to eq(2)
      expect(meetings_order_by_start_time[13].count).to eq(2)
      expect(meetings_order_by_start_time[14].count).to eq(2)
      expect(meetings_order_by_start_time[15].count).to eq(2)
    end
  end
end
