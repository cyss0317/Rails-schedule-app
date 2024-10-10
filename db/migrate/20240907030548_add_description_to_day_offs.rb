class AddDescriptionToDayOffs < ActiveRecord::Migration[7.1]
  def change
    add_column :day_offs, :description, :text
  end
end
