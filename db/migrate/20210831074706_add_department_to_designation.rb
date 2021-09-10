# frozen_string_literal: true

class AddDepartmentToDesignation < ActiveRecord::Migration[6.0]
  def change
    add_reference :designations, :department, null: false
  end
end
