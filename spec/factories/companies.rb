FactoryBot.define do
  factory :company do
    name { Faker::Company.name }

    trait :with_locations do
      create_list(:location, 3)
    end
  end
end
