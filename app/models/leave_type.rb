class LeaveType < ApplicationRecord
  validates :name, format: { with: /\A[a-z A-Z]+\z/,
                             message: 'Leave type name can only contain letters' }

  validates :name, uniqueness: { case_sensitive: false }
  validates :count, numericality: { only_integer: true }
  validates :count, length: { in: 1..20 }
  validates :name, :count, presence: true
end
