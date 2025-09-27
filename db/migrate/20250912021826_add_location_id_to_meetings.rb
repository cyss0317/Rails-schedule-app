class AddLocationIdToMeetings < ActiveRecord::Migration[7.1]
  def change
    add_column :meetings, :location_id, :integer

    add_index :meetings, :location_id
  end
end
