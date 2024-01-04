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
  end
end
