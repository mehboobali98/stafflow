class CreateUserLeaves < ActiveRecord::Migration[6.0]
  def change
    create_table :user_leaves do |t|
      t.references :LeaveType, null: false
      t.references :User, null: false
      t.integer :total_count
      t.integer :remaining_count

      t.timestamps
    end
  end
end
