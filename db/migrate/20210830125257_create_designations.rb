# frozen_string_literal: true

class CreateDesignations < ActiveRecord::Migration[6.0]
  def change
    create_table :designations do |t|
      t.string :name
      t.bigint :company_id
      t.bigint :department_id
      t.timestamps
    end
  end
end
