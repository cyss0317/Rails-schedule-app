require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:company) { create(:company) }
  let(:location) do
    create(:location, :with_relationships,
           name: 'New York Location', meetings_count: 6, company_id: company.id)
  end

  it 'has the correct relationships' do
    expect(location.company).to eq(company)
    expect(location.company.user).is_a?(User)
    expect(location.users.count).to eq(2)
    expect(location.meetings.count).to eq(6)
  end

  describe '#full_address' do
    it 'returns full address' do
      expect(location.full_address).to eq("#{location.street_address} #{location.building_number}, #{location.city}, #{location.state} #{location.zip_code}")
    end
  end
end
