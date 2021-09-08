class CreateUserBenefits < ActiveRecord::Migration[6.0]
  def change
    create_table :user_benefits do |t|
      t.integer :amount
      t.boolean :status
      t.references :benefit, null: false
      t.references :user, null: false
      t.references :company, null: false

      t.timestamps
    end
  end
end
