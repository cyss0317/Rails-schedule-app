# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimeHelper, type: :helper do
  describe '#idx_to_time' do
    it 'returns 12 for 12' do
      expect(helper.idx_to_time(12)).to eq(12)
    end

    it 'returns 1 for 13' do
      expect(helper.idx_to_time(13)).to eq(1)
    end

    it 'returns 11 for 23' do
      expect(helper.idx_to_time(23)).to eq(11)
    end
  end

  describe '#am_pm' do
    it 'returns AM for 01:00' do
      expect(helper.am_pm(Time.zone.parse('2023-01-01 - 01:00:00'))).to eq('AM')
    end
    it 'returns AM for 13:00' do
      expect(helper.am_pm(Time.zone.parse('2023-01-01 - 13:00:00'))).to eq('PM')
    end
  end

  describe '#time_in_am_pm' do
    it 'returns 12:00AM for 00:00' do
      expect(helper.time_in_am_pm(Time.zone.parse('2023-01-01 - 00:00:00'))).to eq('12:00AM')
    end

    it 'returns 12:00PM for 12:00' do
      expect(helper.time_in_am_pm(Time.zone.parse('2023-01-01 - 12:00:00'))).to eq('12:00PM')
    end

    it 'returns 1:00AM for 01:00' do
      expect(helper.time_in_am_pm(Time.zone.parse('2023-01-01 - 01:00:00'))).to eq('1:00AM')
    end

    it 'returns 1:00PM for 13:00' do
      expect(helper.time_in_am_pm(Time.zone.parse('2023-01-01 - 13:00:00'))).to eq('1:00PM')
    end
  end

  describe '#time_from_to' do
    it 'returns 12:00AM - 12:00PM for 00:00 - 12:00' do
      start_time = Time.zone.parse('2023-01-01 - 00:00:00')
      end_time = Time.zone.parse('2023-01-01 - 12:00:00')

      expect(helper.time_from_to(start_time, end_time)).to eq('12:00AM - 12:00PM')
    end

    it 'returns 12:35AM - 8:30PM for 00:35 - 20:30' do
      start_time = Time.zone.parse('2023-01-01 - 00:35:00')
      end_time = Time.zone.parse('2023-01-01 - 20:30:00')

      expect(helper.time_from_to(start_time, end_time)).to eq('12:35AM - 8:30PM')
    end
  end
end
