class CreatePayrolls < ActiveRecord::Migration[6.0]
  def change
    create_table :payrolls do |t|
      t.integer :gross_salary
      t.integer :salary_after_tax
      t.references :user, null: false
      t.references :company, null: false

      t.timestamps
    end
  end
end
