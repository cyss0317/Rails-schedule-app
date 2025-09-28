class ChangeLocationIdToLocationUserIdInUsers < ActiveRecord::Migration[7.1]
  def up
    return unless table_exists?(:users)

    if column_exists?(:users, :location_user_id)
      # Column already there; just ensure index
      add_index :users, :location_user_id, if_not_exists: true
    elsif column_exists?(:users, :location_id)
      # You’re renaming the old column to the new one
      rename_column :users, :location_id, :location_user_id
      add_index :users, :location_user_id, if_not_exists: true
    else
      # Fresh DB: create the column, then index (and optional FK)
      add_column :users, :location_user_id, :bigint
      add_index  :users, :location_user_id, if_not_exists: true
      # add_foreign_key :users, :location_users, column: :location_user_id unless foreign_key_exists?(:users, :location_users)
    end
  end

  def down
    return unless table_exists?(:users)

    # Remove index if present
    remove_index :users, :location_user_id if index_exists?(:users, :location_user_id)

    # Revert rename if appropriate, otherwise drop the column
    if column_exists?(:users, :location_user_id) && !column_exists?(:users, :location_id)
      rename_column :users, :location_user_id, :location_id
    elsif column_exists?(:users, :location_user_id)
      remove_column :users, :location_user_id
    end
  end
end
