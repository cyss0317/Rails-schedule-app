# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Homes', type: :request do
  include Devise::Test::IntegrationHelpers
  describe 'GET /index' do
    before do
      user = create(:user)
      create(:company, user_id: user.id)
      sign_in user
    end

    it 'returns http success' do
      get '/'

      expect(response).to have_http_status(302)
    end
  end
end
