class CreatePayrolls < ActiveRecord::Migration[6.0]
  def change
    create_table :payrolls do |t|
      t.float :gross_salary, null: false
      t.float :salary_after_tax, null: false
      t.float :base_salary, null: false

      t.references :user, null: false
      t.references :company, null: false

      t.timestamps
    end
  end
end
