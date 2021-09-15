class Leave < ApplicationRecord
  validates :name, format: { with: /\A[a-z A-Z]+\z/,
                             message: I18n.t('leave.messages.name_error') }

  validates :name, uniqueness: { scope: :company_id, case_sensitive: false }
  validates :count, numericality: { in: VALID_RANGE, only_integer: true }
  validates :name, :count, presence: true
  has_many :user_leaves, dependent: :nullify
  has_many :users, through: :user_leaves
end
