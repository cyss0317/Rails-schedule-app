class AddCompanyIdToLocation < ActiveRecord::Migration[7.1]
  def change
    add_column :locations, :company_id, :integer
  end
end
