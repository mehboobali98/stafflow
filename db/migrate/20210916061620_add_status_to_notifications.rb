class AddStatusToNotifications < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :status, :integer, default: 0
  end
end
