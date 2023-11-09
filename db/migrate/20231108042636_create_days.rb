class CreateDays < ActiveRecord::Migration[7.1]
  def change
    create_table :days do |t|
      t.integer :month_id, null: true
      t.integer :user_id, null: true

      t.timestamps
    end
    add_index :days, :month_id
    add_index :days, :user_id
  end
end
