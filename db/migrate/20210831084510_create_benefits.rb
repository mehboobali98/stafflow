class CreateBenefits < ActiveRecord::Migration[6.0]
  def change
    create_table :benefits do |t|
      t.string :name, null: false
      t.string :benefit_type, null: false
      t.boolean :status
      t.float :amount, null: false

      t.references :company, null: false

      t.timestamps
    end
  end
end
