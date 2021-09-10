class AddIndexToLeave < ActiveRecord::Migration[6.0]
  def change
    add_index(:leaves, %i[name company_id], unique: true)
  end
end
