FactoryBot.define do
  factory :location do
    company
    name { Faker::Address.city }
    address { Faker::Address.street_address }
    phone_number { Faker::PhoneNumber.phone_number }
    ip_address { Faker::Internet.ip_v4_address }

    trait :with_users do
      after(:create) do |location|
        location.users << create_list(:user, 3, location_id: location.id, company_id: location.company.id)
      end
    end
  end
end
