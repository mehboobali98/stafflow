# frozen_string_literal: true

class AddNameToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :name, :string
  end
end
