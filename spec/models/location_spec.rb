# == Schema Information
#
# Table name: locations
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  address      :string           not null
#  phone_number :string           not null
#  ip_address   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  company_id   :integer
#
require 'rails_helper'

RSpec.describe Location, type: :model do # rubocop:disable Metrics/BlockLength
  describe 'validations' do # rubocop:disable Metrics/BlockLength
    context 'when params are valid' do
      it 'creates a valid location' do
        location = create(:location)

        expect(location).to be_valid
      end
    end

    context 'when params are invalid' do # rubocop:disable Metrics/BlockLength
      it 'is invalid without a name' do
        location = Location.new(
          address: '1234 Main St',
          phone_number: '123-456-7890',
          ip_address: '123.456.789.0'
        )

        expect(location).to be_invalid
      end

      it 'is invalid without an address' do
        location = Location.new(
          name: 'Test Location',
          phone_number: '123-456-7890',
          ip_address: '123.456.789.0'
        )

        expect(location).to be_invalid
      end

      it 'is invalid without a phone number' do
        location = Location.new(
          name: 'Test Location',
          address: '1234 Main St',
          ip_address: '123.456.789.0'
        )

        expect(location).to be_invalid
      end

      it 'is valid without an ip address' do
        location = Location.new(
          name: 'Test Location',
          address: '1234 Main St',
          phone_number: '123-456-7890'
        )

        expect(location).to be_valid
      end

      it 'is invalid without a company id' do
        location = Location.new(
          name: 'Test Location',
          address: '1234 Main St',
          ip_address: '123.456.789.0',
          phone_number: '123-456-7890'
        )

        expect(location).to be_invalid
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:company) }
    it { should have_many(:users) }
  end

  describe 'scopes' do
    describe '.by_company_name' do
      it 'returns locations by company name' do
      end
    end
  end
end
