class ModifyLocationsFields < ActiveRecord::Migration[7.1]
  def change
    rename_column :locations, :address, :street_address

    add_column :locations, :zip_code, :string
    add_column :locations, :building_number, :string
    add_column :locations, :city, :string
    add_column :locations, :country, :string
    add_column :locations, :state, :string
  end
end
