# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  first_name             :string           not null
#  last_name              :string           not null
#  middle_name            :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  color                  :string
#  company_id             :integer
#  location_id            :integer
#  phone_number           :string
#
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
    it { should have_many(:meetings).dependent(:destroy) }
  end

  describe 'instance methods' do
    let(:user) { create(:user, first_name: 'jason', middle_name: 'sung', last_name: 'Choi') }
    describe '#full_name' do
      it 'returns the full name of the user' do
        expect(user.full_name).to eq('Jason Sung Choi')
      end
    end

    describe '#name_and_last_name' do
      it 'returns the name and last name of the user' do
      end
    end

    describe '#trim_params' do

    end
  end
end
