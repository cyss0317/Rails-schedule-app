FactoryBot.define do
  factory :location do
    name { Faker::Address.city }
    address { Faker::Address.street_address }
    phone_number { Faker::PhoneNumber.phone_number }
    ip_address { Faker::Internet.ip_v4_address }
  end
end
