class EnsureLocationsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :locations, if_not_exists: true do |t|
      t.string  :name
      t.string  :street_address
      t.string  :building_number
      t.string  :city
      t.string  :state
      t.string  :zip_code
      t.references :company, foreign_key: true, index: true
      t.timestamps
    end
  end
end
