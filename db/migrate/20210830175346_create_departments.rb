# frozen_string_literal: true

class CreateDepartments < ActiveRecord::Migration[6.0]
  def change
    create_table :departments, &:timestamps
  end
end
