# frozen_string_literal: true

class ChangeMoneyColumnsToDecimal < ActiveRecord::Migration[7.2]
  # `t.float` on MySQL is FLOAT(24) - single precision, roughly seven
  # significant decimal digits. That is under what a salary needs: 1234567.89
  # reads back as 1234570.0, and 100000.10 as 100000.0.
  #
  # null: is repeated on every row because change_column rewrites the whole
  # definition. Leaving it out here drops the NOT NULL these columns carry.
  #
  # [table, column, precision, scale, null]
  COLUMNS = [
    [:applied_benefits, :amount,           15, 2, false],
    [:benefits,         :default_amount,   15, 2, false],
    [:payrolls,         :base_salary,      15, 2, false],
    [:payrolls,         :gross_salary,     15, 2, false],
    [:payrolls,         :salary_after_tax, 15, 2, false],
    [:users,            :base_salary,      15, 2, true],
    [:users_benefits,   :amount,           15, 2, false],
    # A percentage the model bounds at 100, with three places rather than two.
    # The bound below it is `greater_than: 0`, so a scale of 2 would have
    # started rejecting small rates the float column took - the suite already
    # sets 0.001 to mean "as near nothing as the validation allows".
    [:settings,         :tax_rate,          6, 3, true],
    # Leave is counted in days and half days. These were never the demonstrated
    # problem - three significant digits are comfortably inside what a float
    # holds - but a balance is a countable quantity compared for equality, not
    # a measurement, so it belongs in the same column type as the rest.
    [:leaves,           :default_count,     6, 2, false],
    [:user_leaves,      :total_count,       6, 2, false],
    [:user_leaves,      :remaining_count,   6, 2, false]
  ].freeze

  # Whatever the float already rounded away is gone; this fixes what is written
  # from here on, not what is in the table.
  def up
    COLUMNS.each do |table, column, precision, scale, null|
      change_column table, column, :decimal, precision: precision, scale: scale, null: null
    end
  end

  def down
    COLUMNS.each do |table, column, _precision, _scale, null|
      change_column table, column, :float, null: null
    end
  end
end
