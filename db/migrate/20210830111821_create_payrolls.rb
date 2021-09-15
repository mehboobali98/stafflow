class CreatePayrolls < ActiveRecord::Migration[6.0]
  def change
    create_table :payrolls do |t|
      t.float :gross_salary
      t.float :salary_after_tax
      t.float :base_salary

      t.references :user, null: false
      t.references :company, null: false

      t.timestamps
    end
  end
end
