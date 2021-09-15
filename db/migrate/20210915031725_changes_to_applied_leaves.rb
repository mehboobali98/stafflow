class ChangesToAppliedLeaves < ActiveRecord::Migration[6.0]
  def change
    change_column_null :applied_leaves, :user_leave_id, true
    add_column :applied_leaves, :leave_id, :integer
    add_column :applied_leaves, :user_id, :integer
    add_column :applied_leaves, :archived, :boolean, default: false
  end
end
