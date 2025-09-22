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

    trait :with_relationships do
      after(:create) do |user, e|
        # 1) Create locations and keep the instances
        locations = create_list(:location, e.locations_count)

        # 2) Create join rows using those instances (no global pluck)
        locations.take(e.location_users_count).each do |loc|
          create(:location_user, user:, location: loc)
        end

        # 3) Other related data
        create_list(:day_off,  e.day_offs_count,  user:)
        create_list(:meeting,  e.meetings_count,  user:)
      end
    end
  end
end
