class RemoveIndexFromUser < ActiveRecord::Migration[6.0]
  def change
    remove_index :users, :email
    add_index :users, %i[company_id email]
  end
end
