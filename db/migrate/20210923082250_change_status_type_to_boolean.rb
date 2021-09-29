class ChangeStatusTypeToBoolean < ActiveRecord::Migration[6.0]
  def change
    change_column :notifications, :status, :boolean, default: false
  end
end
