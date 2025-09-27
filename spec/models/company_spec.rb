require 'rails_helper'

RSpec.describe Company, type: :model do
  it 'has correct relationships' do
    company = create(:company, :with_relationships, name: 'Cricket')

    expect(company.name).to eq('Cricket')
    expect(company.user).is_a?(User)
    expect(company.locations.count).to eq(2)
    expect(company.locations.first.users.count).to eq(2)
  end
end
