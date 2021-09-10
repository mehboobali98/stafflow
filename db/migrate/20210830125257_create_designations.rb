# frozen_string_literal: true

class CreateDesignations < ActiveRecord::Migration[6.0]
  def change
    create_table :designations do |t|
      t.string :designation_name
      t.bigint :company_id
      t.timestamps
    end
  end
end
