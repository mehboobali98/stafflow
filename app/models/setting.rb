class Setting < ApplicationRecord
  belongs_to :company
  validates :tax_rate, numericality: { only_float: true }
  validates_format_of :theme, with: /\A[a-z]+\z/i
end
