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

  describe 'association' do
    it 'has location_users association' do
      user = create(:user, :with_relationships, meetings_count: 3)

      expect(user.location_users.count).to eq(2)
      expect(user.day_offs.count).to eq(2)
      expect(user.meetings.count).to eq(3)
      expect(user.locations.count).to eq(2)
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
        create(:user, first_name: 'DEMO')
        create(:user, email: 'demo_user@gmail.com')
        create(:user, email: 'user_demo@gamil.com')
        user = create(:user)

        expect(User.without_demo_user).to eq([user])
      end
    end
  end

  describe '#can_work_for_time_frame?(start_time, end_time, date)' do
    let(:user) { create(:user, email: 'test@test.com') }

    let(:date) { Date.parse('2025-07-21') }
    let(:day_off) do
      create(:day_off, start_time: DateTime.parse("#{date} 10:00:00 -5:00"),
                       end_time: DateTime.parse("#{date} 18:00:00 -5:00"), user_id: user.id)
    end
    # let(:shift) do
    #   create(:meeting, start_time: DateTime.parse("#{date} 10:00:00 -5:00"),
    #                    end_time: DateTime.parse("#{date} 18:00:00 -5:00"), user_id: user.id)
    # end

    it "returns true if the user's day_off for the date does NOT overlap with the given time frame" do
      shift = create(:meeting, start_time: DateTime.parse("#{date} 10:00:00 -5:00"),
                               end_time: DateTime.parse("#{date} 18:00:00 -5:00"), user_id: user.id)

      user.day_offs << day_off
      user.meetings << shift

      expect(user.can_work_for_time_frame?(shift.start_time, shift.end_time, date)).to be false
    end

    it "returns false if the user's day_off for the date overlaps with the given time frame" do
      shift = create(:meeting, start_time: DateTime.parse("#{date} 19:00:00 -5:00"),
                               end_time: DateTime.parse("#{date} 23:00:00 -5:00"), user_id: user.id)

      user.day_offs << day_off
      user.meetings << shift

      expect(user.can_work_for_time_frame?(shift.start_time, shift.end_time, date)).to be true
    end
  end
end
