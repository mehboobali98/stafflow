class RemoveSenderFromNotifications < ActiveRecord::Migration[6.0]
  def change
    remove_column :notifications, :sender_id, :time
  end
end
