# frozen_string_literal: true

# Leave model
class Leave < ApplicationRecord
  validates :name, format: { with: /\A[a-z A-Z]+\z/,
                             message: I18n.t('leave.messages.name_error') }

  validates :name,
            uniqueness: { scope: :company_id, case_sensitive: false, message: I18n.t('leave.messages.duplicate_error') }
  validates :count, numericality: { in: VALID_LEAVE_RANGE }
  validates :name, :count, presence: true
  has_many :user_leaves, dependent: :nullify
  has_many :users, through: :user_leaves
  has_many :applied_leaves
  belongs_to :company
end
