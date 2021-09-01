# frozen_string_literal: true

class CreatePayrolls < ActiveRecord::Migration[6.0]
  def change
    create_table :payrolls do |t|
      t.integer :base_salary
      t.integer :tax

      t.timestamps
    end
  end
end
