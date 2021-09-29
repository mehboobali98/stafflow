class RemoveUserFromAppliedBenefits < ActiveRecord::Migration[6.0]
  def change
    change_table :applied_benefits do |t|
      t.remove_references :user
    end
  end
end
