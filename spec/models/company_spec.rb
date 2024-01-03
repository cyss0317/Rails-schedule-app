require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'validations' do
    it 'creates a valid company' do
      company = create(:company)

      expect(company).to be_valid
    end

    it 'is invalid without a name' do
      company = Company.new

      expect(company).to be_invalid
    end
  end
end
