class AddStateToAppliedLeaves < ActiveRecord::Migration[6.0]
  def change
    add_column :applied_leaves, :state, :string
  end
end
