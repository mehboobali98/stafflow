class AddTaxToSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :settings, :tax, :integer
  end
end
