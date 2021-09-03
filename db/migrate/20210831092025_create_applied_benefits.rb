class CreateAppliedBenefits < ActiveRecord::Migration[6.0]
  def change
    create_table :applied_benefits do |t|
      t.integer :amount
      t.references :user_benefit, null: false
      t.references :payroll, null: false
      t.references :user, null: false

      t.timestamps
    end
  end
end
