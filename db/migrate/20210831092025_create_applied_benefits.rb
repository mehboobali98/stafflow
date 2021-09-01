class CreateAppliedBenefits < ActiveRecord::Migration[6.0]
  def change
    create_table :applied_benefits do |t|
      t.integer :amount
      t.references :user_benefit, null: false, foreign_key: true
      t.references :payroll, null: false, foreign_key: true

      t.timestamps
    end
  end
end
