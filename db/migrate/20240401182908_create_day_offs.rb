class CreateDayOffs < ActiveRecord::Migration[7.1]
  def change
    create_table :day_offs do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer :user_id

      t.timestamps
    end
    add_index :day_offs, :user_id
    add_index :day_offs, :end_time
  end
end
