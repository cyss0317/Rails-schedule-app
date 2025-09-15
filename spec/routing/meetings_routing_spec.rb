# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingsController, type: :routing do
  let(:location) { create(:location) }
  describe 'routing' do
    it 'routes to #index' do
      expect(get: location_meetings_path(location)).to route_to('meetings#index', location_id: location.id.to_s)
    end

    it 'routes to #new' do
      expect(get: new_location_meeting_path(location)).to route_to('meetings#new', location_id: location.id.to_s)
    end

    it 'routes to #show' do
      expect(get: '/meetings/1').to route_to('meetings#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/meetings/1/edit').to route_to('meetings#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: location_meetings_path(location)).to route_to('meetings#create', location_id: location.id.to_s)
    end

    it 'routes to #update via PUT' do
      expect(put: '/meetings/1').to route_to('meetings#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/meetings/1').to route_to('meetings#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/meetings/1').to route_to('meetings#destroy', id: '1')
    end
  end
end
