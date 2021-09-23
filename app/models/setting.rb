class Setting < ApplicationRecord
  belongs_to :company
  validates :tax_rate, numericality: { only_float: true }
end
