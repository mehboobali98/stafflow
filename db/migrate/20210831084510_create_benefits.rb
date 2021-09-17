class CreateBenefits < ActiveRecord::Migration[6.0]
  def change
    create_table :benefits do |t|
      t.string :name, null: false
      t.string :benefit_type, null: false
      t.boolean :status
      t.float :amount, null: false

      t.references :company, null: false

      add_index :benefits, :company_id
      add_index :benefits, :user_id

      t.timestamps
    end
  end
end
