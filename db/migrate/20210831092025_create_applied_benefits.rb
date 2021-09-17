class CreateAppliedBenefits < ActiveRecord::Migration[6.0]
  def change
    create_table :applied_benefits do |t|
      t.float :amount, null: false

      t.references :users_benefit
      t.references :payroll
      t.references :user, null: false
      t.references :benefit, null: false
      t.references :company, null: false

      add_index :applied_benefits, :company_id
      add_index :applied_benefits, :user_id
      t.timestamps
    end
  end
end
