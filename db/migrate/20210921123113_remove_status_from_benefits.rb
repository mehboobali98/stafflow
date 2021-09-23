class RemoveStatusFromBenefits < ActiveRecord::Migration[6.0]
  def change
    remove_column :benefits, :status
  end
end
