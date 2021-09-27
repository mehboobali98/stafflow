class RemoveLeaveResetNotNullConstraint < ActiveRecord::Migration[6.0]
  def change
    change_column_null :settings, :leave_resets_at, true
  end
end
