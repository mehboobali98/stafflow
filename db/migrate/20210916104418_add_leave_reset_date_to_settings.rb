class AddLeaveResetDateToSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :settings, :leave_resets_at, :datetime, null: false
  end
end
