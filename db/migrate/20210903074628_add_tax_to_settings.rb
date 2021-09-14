class AddTaxToSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :settings, :tax, :float
  end
end
