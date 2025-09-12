# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    transient { location_users_count { 2 } }
    transient { day_offs_count { 2 } }
    transient { meetings_count { 2 } }
    transient { locations_count { 2 } }

    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.middle_name }
    last_name { Faker::Name.last_name }
    password { Faker::Internet.password }

    trait(:with_relationships) do
      after(:create) { |user, e| create_list(:location_user, e.location_users_count, user:) }
      after(:create) { |user, e| create_list(:day_off, e.day_offs_count, user:) }
      after(:create) { |user, e| create_list(:meeting, e.meetings_count, user:) }
      after(:create) { |_user, e| create_list(:location, e.locations_count) }
    end
  end
end
