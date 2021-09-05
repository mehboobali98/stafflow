class CreateAppliedLeaves < ActiveRecord::Migration[6.0]
  def change
    create_table :applied_leaves do |t|
      t.references :user_leave, null: false
      t.date :applied_at, null: false
      t.date :applied_till, null: false
      t.timestamps
    end
  end
end
