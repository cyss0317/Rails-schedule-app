# frozen_string_literal: true

FactoryBot.define do
  factory :day_off do
    association :location
    association :user

    start_time { '2022-04-01 18:29:08' }
    end_time { '2022-04-01 18:29:08' }
    user_id { user.id }
    location_id { location.id }
    description { Faker::Address.full_address }
  end
end
