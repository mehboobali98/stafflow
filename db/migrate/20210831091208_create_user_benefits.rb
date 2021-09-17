class CreateUserBenefits < ActiveRecord::Migration[6.0]
  def change
    create_table :users_benefits do |t|
      t.float :amount, null: false
      t.boolean :status

      t.references :benefit, null: false
      t.references :user, null: false
      t.references :company, null: false

      add_index :users_benefits, :company_id
      add_index :users_benefits, :user_id

      t.timestamps
    end
  end
end
