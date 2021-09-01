class CreateUserBenefits < ActiveRecord::Migration[6.0]
  def change
    create_table :user_benefits do |t|
      t.integer :amount
      t.boolean :status
      t.references :benefit, null: false, foreign_key: true

      t.timestamps
    end
  end
end
