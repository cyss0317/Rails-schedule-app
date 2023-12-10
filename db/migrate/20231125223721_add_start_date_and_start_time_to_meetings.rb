class AddStartDateAndStartTimeToMeetings < ActiveRecord::Migration[7.1]
  def change
    add_column :meetings, :start_date, :datetime
    add_column :meetings, :time, :time
  end
end
