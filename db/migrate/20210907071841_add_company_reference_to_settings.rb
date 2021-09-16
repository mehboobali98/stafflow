class AddCompanyReferenceToSettings < ActiveRecord::Migration[6.0]
  def change
    add_reference :settings, :company
  end
end
