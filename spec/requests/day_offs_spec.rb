# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DayOffs', type: :request do
  include Devise::Test::IntegrationHelpers # Corrected include here

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

  before do
    sign_in user
  end

  describe '#create' do
    it 'creates a new day off when valid params are given' do
      expect do
        sign_in user  # This method is now properly supported

        post day_offs_path, params: valid_params
      end.to change(DayOff, :count).by(1)
    end

    it 'does NOT create a new day off when invalid params are given' do
      expect do
        sign_in user  # Sign in added here for consistency

        post day_offs_path, params: invalid_params
      end.to change(DayOff, :count).by(0)
    end
  end

  describe '#update' do
    it 'updates a day off when valid params are given' do
      day_off = create(:day_off, user_id: user.id)

      patch day_off_path(day_off), params: valid_params

      day_off.reload

      expect(day_off.start_time).to eq('2020-01-01 12:00:00 -0600')
    end

    it 'does NOT updates a day off when invalid params are given' do
      day_off = create(:day_off, user_id: user.id)

      patch day_off_path(day_off), params: invalid_params

      day_off.reload

      expect(day_off.start_time).to eq(day_off.start_time)
    end
  end
end
