class AddCompanyToEvent < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :company_id, :integer
    add_index :events, :company_id
  end
end
