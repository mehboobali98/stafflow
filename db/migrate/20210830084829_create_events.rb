class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :event_name
      t.string :event_start_date_time
      t.string :event_end_date_time

      t.timestamps
    end
  end
end
