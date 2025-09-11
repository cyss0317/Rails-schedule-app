require 'rails_helper'

RSpec.describe LocationUser, type: :model do
  it "has belongs_to relationship to user and company" do
    location_user = create(:location_user)

    expect(location_user.user).not_to be_nil
    expect(location_user.user).to be_a(User)
    expect(location_user.company).not_to be_nil
    expect(location_user.company).to be_a(Company)
  end
end
