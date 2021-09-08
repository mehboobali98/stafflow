class CreateBenefits < ActiveRecord::Migration[6.0]
  def change
    create_table :benefits do |t|
      t.string :name
      t.string :benefit_type
      t.references :company, null: false

      t.timestamps
    end
  end
end
