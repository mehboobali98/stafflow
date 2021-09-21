class CreateUserLeaves < ActiveRecord::Migration[6.0]
  def change
    create_table :user_leaves do |t|
      t.float :total_count, null: false
      t.float :remaining_count, null: false
      t.references :leave
      t.references :user, null: false
      t.references :company, null: false

      t.timestamps
    end
    add_index(:user_leaves, %i[user_id leave_id], unique: true)
  end
end
