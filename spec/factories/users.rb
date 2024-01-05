# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    company
    location
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.middle_name }
    last_name { Faker::Name.last_name }
    password { Faker::Internet.password }
    color { Faker::Color.hex_color }

    trait :under_texas_central_connection do
      company { Company.find_by(name: 'Central Texas Connection') }
      # location { Location.find_by(name: 'Cricket Wireless') }
    end
  end
end
