class AddUserIdAndIndexCompanies < ActiveRecord::Migration[7.1]
  def change
    return unless table_exists?(:companies)

    add_column :companies, :user_id, :integer unless column_exists?(:companies, :user_id)
    add_index  :companies, :user_id unless index_exists?(:companies, :user_id)
  end
end
