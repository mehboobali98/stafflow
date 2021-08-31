class ChangeColumnToDateTime < ActiveRecord::Migration[6.0]
  def change
    change_table :events do |t|
      t.change :start_date_time, :datetime
      t.change :end_date_time, :datetime
    end
  end
end
