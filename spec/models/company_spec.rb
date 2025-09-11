require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:user) { create(:user) }
  let(:company) { create(:company, user_id: user.id) }
  it 'belongs to a user' do
    company = create(:company, name: 'Cricket', user_id: user.id)

    expect(company.name).to eq('Cricket')
    expect(company.user).to eq(user)
  end
end
