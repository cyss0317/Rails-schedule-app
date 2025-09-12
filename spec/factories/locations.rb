FactoryBot.define do
  factory :location do
    association :company

    transient { location_user_count { 2 } }

    name { Faker::Company.name }
    street_address { Faker::Address.street_address }
    building_number { Faker::Address.building_number }
    phone_number { Faker::PhoneNumber.phone_number }
    zip_code { Faker::Address.zip_code }
    city { Faker::Address.city }
    state { Faker::Address.state }
    country { Faker::Address.country }

    trait(:with_relationships) do
      after(:create) { |location, e| create_list(:location_user, e.location_user_count, location:) }
    end
  end
end
