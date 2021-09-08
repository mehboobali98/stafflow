class AddDepartmentRefToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :department, null: false
  end
end
