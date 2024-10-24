# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.middle_name }
    last_name { Faker::Name.last_name }
    password { Faker::Internet.password }

    trait(:admin) do
      after(:create) do |user|
        Flipper.enable(:admin, Flipper::Actor.new(user.email))
      end
    end
  end
end
