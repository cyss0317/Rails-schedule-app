require 'rails_helper'

RSpec.describe LocationUser, type: :model do
  describe 'validations' do
    it 'should raise an error when user_id or location_id is not unique' do
      user = create(:user)
      company = create(:company, user:)
      location = create(:location, company:)
      create(:location_user, location_id: location.id, user_id: user.id)
      expect do
        create(:location_user, location_id: location.id, user_id: user.id)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
  it 'has belongs_to relationship to user and company' do
    location_user = create(:location_user)

    expect(location_user.user).not_to be_nil
    expect(location_user.user).is_a?(User)
    expect(location_user.location).not_to be_nil
    expect(location_user.location).is_a?(Location)
  end
end
