# frozen_string_literal: true

FactoryBot.define do
  factory :day_off do
    user
    start_time { '2022-04-01 18:29:08' }
    end_time { '2022-04-01 18:29:08' }
    user_id { user.id }
    description { Faker::Address.full_address }
  end
end
