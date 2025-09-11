require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:company) { create(:company) }
  let(:location) { create(:location, name: 'New York Location', company_id: company.id) }
  it 'belongs to a company' do
    expect(location.company).to eq(company)
    expect(location.company.user).to_not be_nil
  end
end
