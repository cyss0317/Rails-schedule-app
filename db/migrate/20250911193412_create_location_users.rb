class CreateLocationUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :location_users do |t|
      t.integer :user_id
      t.integer :location_id
      t.string :role, default: 'user'

      t.timestamps
    end

    add_index :location_users, :location_id
  end
end
