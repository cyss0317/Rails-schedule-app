FactoryBot.define do
  factory :company do
    transient { locations_count { 2 } }

    association :user
    name { Faker::Company.name }

    trait(:with_relationships) do
      after(:create) { |company, e| create_list(:location, e.locations_count, :with_relationships, company:) }
    end
  end
end
