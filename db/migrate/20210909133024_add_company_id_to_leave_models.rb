class AddCompanyIdToLeaveModels < ActiveRecord::Migration[6.0]
  def change
    add_reference :applied_leaves, :company, null: false
    add_reference :user_leaves, :company, null: false
  end
end
