class Leave < ApplicationRecord
  validates :name, format: { with: /\A[a-z A-Z]+\z/,
                             message: I18n.t('leave.messages.name_error') }

  validates :name, uniqueness: { scope: :company_id, case_sensitive: false }
  validates :count, numericality: { only_integer: true }
  validates :count, length: { in: 1..20 }
  validates :name, :count, presence: true
  has_many :user_leaves
  has_many :users, through: :user_leaves
end
