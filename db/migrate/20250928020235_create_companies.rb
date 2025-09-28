class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies, if_not_exists: true do |t|
      t.string  :name, null: false
      t.integer :user_id # only if it exists in schema
      t.timestamps
    end

    add_index :companies, :user_id unless index_exists?(:companies, :user_id)
  end
end
