# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Homes', type: :request do
  include Devise::Test::IntegrationHelpers
  describe 'GET /index' do
    before do
      sign_in create(:user)
    end

    it 'returns http success' do
      get '/'

      expect(response).to have_http_status(:success)
    end
  end
end
