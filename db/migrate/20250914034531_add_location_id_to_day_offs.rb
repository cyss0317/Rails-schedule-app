class AddLocationIdToDayOffs < ActiveRecord::Migration[7.1]
  def change
    add_column :day_offs, :location_id, :integer

    add_index :day_offs, :location_id
  end
end
