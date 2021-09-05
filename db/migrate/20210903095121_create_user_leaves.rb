class CreateUserLeaves < ActiveRecord::Migration[6.0]
  def change
    create_table :user_leaves do |t|
      t.references :leave, null: false
      t.references :user, null: false
      t.integer :total_count
      t.integer :remaining_count

      t.timestamps
    end
  end
end
