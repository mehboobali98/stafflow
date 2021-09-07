# frozen_string_literal: true

class AddCompanyRefToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :company, null: false
  end
end
