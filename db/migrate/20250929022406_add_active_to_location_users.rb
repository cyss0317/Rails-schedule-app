class AddActiveToLocationUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :location_users, :active, :boolean

    add_index :location_users, :active
  end
end
