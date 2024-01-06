# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  first_name             :string           not null
#  last_name              :string           not null
#  middle_name            :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  color                  :string
#  company_id             :integer
#  location_id            :integer
#  phone_number           :string
#
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
