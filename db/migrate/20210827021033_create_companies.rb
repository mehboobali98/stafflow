class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :subdomain, null: false
      t.timestamps
    end

    add_index(:companies, %i[subdomain], unique: true)
  end
end
