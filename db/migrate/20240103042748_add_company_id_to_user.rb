class AddCompanyIdToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :company_id, :integer
    add_column :users, :location_id, :integer

    add_index :users, :company_id
    add_index :users, :location_id
  end
end
