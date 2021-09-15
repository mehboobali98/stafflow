class ChangeUserLeaveTable < ActiveRecord::Migration[6.0]
  def change
    change_column :user_leaves, :total_count, :float
    change_column :user_leaves, :remaining_count, :float
  end
end
