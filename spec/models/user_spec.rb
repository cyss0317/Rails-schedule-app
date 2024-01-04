# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  context 'validation tests' do
    it 'ensures duplicated email address' do
      create(:user, email: 'test@test.com')
      dup_user = User.new(email: 'test@test.com').save

      expect(dup_user).to eq(false)
    end

    it 'ensures email presence' do
      user = User.new(
        first_name: 'First', middle_name: 'Middle', last_name: 'Last', email: '',
        password: '12341234'
      ).save

      expect(user).to eq(false)
    end
  end

  describe 'associations' do
    it { should belong_to(:company) }
    it { should belong_to(:location) }
    it { should have_many(:meetings).dependent(:destroy)}
  end
end
