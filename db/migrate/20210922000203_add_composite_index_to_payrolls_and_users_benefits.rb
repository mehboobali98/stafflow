class AddCompositeIndexToPayrollsAndUsersBenefits < ActiveRecord::Migration[6.0]
  def change
    add_index(:payrolls, %i[company_id user_id])
    add_index(:users_benefits, %i[company_id user_id])
  end
end
