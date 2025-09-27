# frozen_string_literal: true

FactoryBot.define do
  factory :meeting do
    location
    user
    transient { meetings_count { 2 } }
    name { 'MyString' }
    start_time { '2023-11-17 23:56:19' }
    end_time { '2023-11-17 23:56:19' }

    trait(:morning_shift) do
      start_time { Time.zone.now.beginning_of_day + 8.hours }
      end_time { Time.zone.now.beginning_of_day + 15.hours }
    end

    trait(:dinner_shift) do
      start_time { Time.zone.now.beginning_of_day + 16.hours }
      end_time { Time.zone.now.beginning_of_day + 21.hours }
    end

    trait(:hour_from) do
      start_time { start_time }
      end_time { start_time + 2.hour }
    end

    trait(:create_test_case) do
    end

    trait(:with_relationships) do
      association :user
      association :location
    end

    trait(:with_association) do
      association :user
      association :location
    end
  end
end
