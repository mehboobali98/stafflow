class AddSalaryToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :salary, :integer
  end
end
