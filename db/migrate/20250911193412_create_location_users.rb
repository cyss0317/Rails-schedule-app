class CreateLocationUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :location_users do |t|
      t.integer :user_id
      t.integer :company_id
      t.string :role

      t.timestamps
    end

    add_index :location_users, :company_id
  end

end
