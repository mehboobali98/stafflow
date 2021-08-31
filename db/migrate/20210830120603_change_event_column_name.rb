class ChangeEventColumnName < ActiveRecord::Migration[6.0]
  def change
    change_table :events do |t|
      t.rename :event_end_date_time, :end_date_time
    end
  end
end
