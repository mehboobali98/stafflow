# frozen_string_literal: true

class UsersBenefit < ApplicationRecord
  sequenceid :company, :users_benefits
  belongs_to :benefit
  belongs_to :user
  belongs_to :company
  has_many :applied_benefits, dependent: :nullify
  validates :amount, presence: { message: I18n.t('users_benefit.validation.presence.') }, numericality: true
end
