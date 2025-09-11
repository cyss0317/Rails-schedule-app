FactoryBot.define do
  factory :location do
    company
    name { Faker::Name.name.company_name }
    street_address { Faker::Address.street_address }
    building_number { Faker::Address.building_number }
    phone_number { Faker::PhoneNumber.phone_number }
    zip_code { Faker::Address.zip_code }
    city { Faker::Address.city }
    state { Faker::Address.state }
    country { Faker::Address.country }
  end
end
