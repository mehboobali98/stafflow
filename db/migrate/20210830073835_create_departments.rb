# frozen_string_literal: true

class CreateDepartments < ActiveRecord::Migration[6.0]
  def change
    create_table :departments do |t|
      t.string :name
      t.bigint :company_id
      t.timestamps
    end
  end
end
