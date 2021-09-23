class CreateAppliedBenefits < ActiveRecord::Migration[6.0]
  def change
    create_table :applied_benefits do |t|
      t.float :amount, null: false

      t.references :users_benefit
      t.references :payroll, null: false
      t.references :user, null: false
      t.references :benefit, null: false
      t.references :company, null: false

      t.timestamps
    end
  end
end
