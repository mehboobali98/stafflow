# frozen_string_literal: true

class CreateAppliedBenefits < ActiveRecord::Migration[6.0]
  def change
    create_table :applied_benefits do |t|
      t.integer :amount
      t.references :user_benefit, null: false
      t.references :payroll
      t.references :user, null: false
      t.references :benefit, null: false
      t.references :company, null: false

      t.timestamps
    end
  end
end
