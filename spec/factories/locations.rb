# == Schema Information
#
# Table name: locations
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  address      :string           not null
#  phone_number :string           not null
#  ip_address   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  company_id   :integer
#
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
