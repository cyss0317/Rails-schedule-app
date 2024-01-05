class MeetingSeeder
  def self.seed!
    user_id_array = User.all.pluck(:id)

    5.times do |i|
      # morning shift
      starting_time = Time.new.in_time_zone.noon + i.days - 4.hour
      Meeting.create!(
        name: "Meeting #{i}",
        user_id: user_id_array.sample,
        start_time: starting_time,
        end_time: starting_time + (4 + i).hour
      )
      Meeting.create!(
        name: "Meeting #{i}",
        user_id: user_id_array.sample,
        start_time: starting_time + 2.hour,
        end_time: starting_time + (4 + i).hour
      )
      # dinner shift
      starting_time = Time.new.in_time_zone.noon + i.days + 3.hour
      Meeting.create!(
        name: "Meeting #{i}",
        user_id: user_id_array.sample,
        start_time: starting_time,
        end_time: starting_time + i.hour
      )
      Meeting.create!(
        name: "Meeting #{i}",
        user_id: user_id_array.sample,
        start_time: starting_time,
        end_time: starting_time + (2 + i).hour
      )
    end
  end
end
