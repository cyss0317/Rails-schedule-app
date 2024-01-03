require 'rails_helper'

RSpec.describe Location, type: :model do
  describe 'validations' do
    it 'creates a valid location' do
      location = create(:location)

      expect(location).to be_valid
    end

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
  end

  describe 'associations' do
    it 'has many users' do
      location = create(:location)
      
      expect(location).to respond_to(:users)
    end
  end
end
