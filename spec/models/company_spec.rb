# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
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

  describe 'associations' do
    it { should have_many(:users)}
  end
end
