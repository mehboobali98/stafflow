class CreateAppliedLeaves < ActiveRecord::Migration[6.0]
  def change
    create_table :applied_leaves do |t|
      t.date :applied_from, null: false
      t.date :applied_till, null: false
      t.string :state, null: false
      t.integer :leave_duration_id, null: false
      t.boolean :archived, default: false
      t.references :user_leave, null: true
      t.references :company, null: false
      t.references :user
      t.references :leave

      t.timestamps
    end
    add_index(:applied_leaves, %i[user_id user_leave_id])
  end
end
