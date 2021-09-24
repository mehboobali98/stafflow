class AddCompanyReferenceToNotifications < ActiveRecord::Migration[6.0]
  def change
    add_reference :notifications, :company, foreign_key: true
  end
end
