class CreateMeetings < ActiveRecord::Migration[7.1]
  def change
    create_table :meetings do |t|
      t.string :name
      t.datetime :start_time
      t.datetime :end_time
      t.integer :user_id

      t.timestamps
    end
    add_index :meetings, :user_id
  end
end
