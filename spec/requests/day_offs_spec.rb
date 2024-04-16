# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DayOffs', type: :request do
  describe '#create' do
    let!(:user) { create(:user) }
    let(:valid_params) do
      {
        'day_offs' => {
          'start_time' => '2020-01-01 12:00:00 -0600',
          'end_time' => '2020-01-01 14:00:00 -0600',
          'user_id' => user.id
        }
      }
    end
    let(:invalid_params) do
      {
        'day_offs' => {
          'start_time' => '',
          'end_time' => '',
          'user_id' => user.id
        }
      }
    end

    it 'creates a new day off when valid params are given' do
      expect do
        post day_offs_path, params: valid_params
      end.to change(DayOff, :count).by(1)
    end
    it 'does NOT create a new day off when invalid params are given' do
      expect do
        post day_offs_path, params: invalid_params
      end.to change(DayOff, :count).by(0)
    end
  end
end
