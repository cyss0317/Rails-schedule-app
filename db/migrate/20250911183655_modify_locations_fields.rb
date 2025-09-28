class ModifyLocationsFields < ActiveRecord::Migration[7.1]
  def up
    return unless table_exists?(:locations)

    # examples — keep only the ones you actually need
    rename_column :locations, :address, :street_address if column_exists?(:locations, :address)

    change_column_null :locations, :street_address, false if column_exists?(:locations, :street_address)

    add_column :locations, :building_number, :string unless column_exists?(:locations, :building_number)

    return if index_exists?(:locations, :company_id)

    add_index :locations, :company_id
  end

  def down
    return unless table_exists?(:locations)

    remove_column :locations, :building_number if column_exists?(:locations, :building_number)

    change_column_null :locations, :street_address, true if column_exists?(:locations, :street_address)

    if column_exists?(:locations, :street_address) && !column_exists?(:locations, :address)
      rename_column :locations, :street_address, :address
    end

    return unless index_exists?(:locations, :company_id)

    remove_index :locations, :company_id
  end
end
