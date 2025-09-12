require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:company) { create(:company) }
  let(:location) { create(:location, :with_relationships, name: 'New York Location', company_id: company.id) }

  it 'has the correct relationships' do
    expect(location.company).to eq(company)
    expect(location.company.user).is_a?(User)
    expect(location.users.count).to eq(2)
  end
end
