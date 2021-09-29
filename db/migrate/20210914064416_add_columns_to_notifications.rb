class AddColumnsToNotifications < ActiveRecord::Migration[6.0]
  def change
    add_reference :notifications, :sender, references: :user, index: true
    add_reference :notifications, :recipient, references: :user, index: true
    add_column :notifications, :body, :string
    add_column :notifications, :time, :datetime
  end
end
