class ChangeLeaveColumnName < ActiveRecord::Migration[6.0]
  def change
    rename_column :leaves, :count, :default_count
  end
end
