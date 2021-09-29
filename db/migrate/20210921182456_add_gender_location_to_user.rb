class AddGenderLocationToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :gender, :string
    add_column :users, :city, :string
    add_column :users, :country, :string
  end
end
