class ChangeColumnName < ActiveRecord::Migration[6.0]
  def change
    change_table :events do |t|
      t.rename :end_date_time, :end_time
      t.rename :start_date_time, :start_time
    end
  end
end
