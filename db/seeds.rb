# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user_id_array = User.all.pluck(:id)

5.times do |i|
  starting_time = Time.now + i.days
  Meeting.create(
    name: "Meeting #{i}",
    user_id: user_id_array.sample,
    start_time: starting_time,
    end_time: starting_time + 1.hour
  )

  starting_time = Time.now - i.days
  Meeting.create(
    name: "Meeting #{i}",
    user_id: user_id_array.sample,
    start_time: starting_time,
    end_time: starting_time + 1.hour
  )
end

if user_id_array.length < 4

end