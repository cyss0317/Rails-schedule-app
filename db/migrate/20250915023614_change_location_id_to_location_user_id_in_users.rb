class ChangeLocationIdToLocationUserIdInUsers < ActiveRecord::Migration[7.1]
  def up
    remove_index :users, name: :index_users_on_location_id, if_exists: true

    if column_exists?(:users, :location_id) && !column_exists?(:users, :location_user_id)
      rename_column :users, :location_id, :location_user_id
    end

    add_index :users, :location_user_id, if_not_exists: true
  end

  def down
    remove_index :users, name: :index_users_on_location_id, if_exsits: true

    if column_exists?(:users, :location_user_id) && !column_exists?(:users, :location_id)
      rename_column :users, :location_user_id, :location_id
    end

    add_index :users, :location_id,
              name: :index_users_on_location_id,
              if_not_exists: true
  end
end
