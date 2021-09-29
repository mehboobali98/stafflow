class CreateLeaves < ActiveRecord::Migration[6.0]
  def change
    create_table :leaves do |t|
      t.string :name, null: false
      t.float :count, null: false
      t.references :company, null: false

      t.timestamps
    end
    add_index(:leaves, %i[company_id name], unique: true)
  end
end
