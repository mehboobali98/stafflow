class RemoveImageFromDepartment < ActiveRecord::Migration[6.0]
  def change
    remove_column :departments, :image_url
  end
end
