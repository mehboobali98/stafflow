class AddDesignationReferenceToUser < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :designation
  end
end
