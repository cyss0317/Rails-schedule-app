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
      user = User.new(first_name: 'First', middle_name: 'Middle', last_name: 'Last', email: '',
                      password: '12341234').save
      expect(user).to eq(false)
    end
  end

  describe 'scopes' do
    describe '.sort_by_first_name' do
      it 'returns users sorted by first name' do
        user1 = create(:user, first_name: 'Zebra')
        user2 = create(:user, first_name: 'Apple')
        user3 = create(:user, first_name: 'Zombie')

        expect(User.sort_by_first_name).to eq([user2, user1, user3])
      end
    end

    describe '.without_demo_user' do
      it 'returns users without demo users' do
        create(:user, first_name: 'Demo')
        create(:user, email: 'demo_user@gmail.com')
        create(:user, email: 'user_demo@gamil.com')
        user = create(:user)

        expect(User.without_demo_user).to eq([user])
      end
    end
  end
end
