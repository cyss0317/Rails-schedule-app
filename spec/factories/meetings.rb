# frozen_string_literal: true

FactoryBot.define do
  factory :meeting do
    user
    name { 'MyString' }
    start_time { '2023-11-17 23:56:19' }
    end_time { '2023-11-17 23:56:19' }
    user_id { user.id }
  end
end
