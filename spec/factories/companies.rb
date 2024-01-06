# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :company do
    name { Faker::Company.name }

    trait :with_locations do
      after(:create) do |company|
        locations = create_list(:location, 2, company_id: company.id)
        create_list(:user, 8, company_id: company.id, location_id: locations[(0..locations.length).to_a.sample].id)
      end
    end
  end
end
