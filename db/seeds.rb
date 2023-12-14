# frozen_string_literal: true

require 'factory_bot_rails'

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

FactoryBot.create(:user, email: 'test@test.com', password: 'asdfasdf', color: Faker::Color.hex_color) unless User.find_by(email: 'test@test.com')

user_id_array = User.all.pluck(:id)

user_id_array << FactoryBot.create(:user, color: Faker::Color.hex_color) until user_id_array.length == 4 if user_id_array.length < 4

5.times do |i|
  # morning shift
  starting_time = Time.new.noon + i.days - 4.hour
  Meeting.create(
    name: "Meeting #{i}",
    user_id: user_id_array.sample,
    start_time: starting_time,
    end_time: starting_time + (4 + i).hour
  )
  Meeting.create(
    name: "Meeting #{i}",
    user_id: user_id_array.sample,
    start_time: starting_time + 2.hour,
    end_time: starting_time + (4 + i).hour
  )
  # dinner shift
  starting_time = Time.now.noon + i.days + 3.hour
  Meeting.create(
    name: "Meeting #{i}",
    user_id: user_id_array.sample,
    start_time: starting_time,
    end_time: starting_time + i.hour
  )
  Meeting.create(
    name: "Meeting #{i}",
    user_id: user_id_array.sample,
    start_time: starting_time,
    end_time: starting_time + (2 + i).hour
  )
end
