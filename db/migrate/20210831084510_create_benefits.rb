class CreateBenefits < ActiveRecord::Migration[6.0]
  def change
    create_table :benefits do |t|
      t.string :name, null: false
      t.float :default_amount, null: false

      t.references :company, null: false

      t.timestamps
    end
  end
end
