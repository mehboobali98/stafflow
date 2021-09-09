class AddCompanyIdToLeave < ActiveRecord::Migration[6.0]
  def change
    add_reference :leaves, :company, null: false
  end
end
