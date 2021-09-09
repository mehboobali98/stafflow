class AddLeaveDurationIdToAppliedLeaves < ActiveRecord::Migration[6.0]
  def change
    add_column :applied_leaves, :leave_duration_id, :integer
  end
end
