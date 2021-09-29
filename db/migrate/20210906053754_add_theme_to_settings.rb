class AddThemeToSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :settings, :theme, :string
  end
end
