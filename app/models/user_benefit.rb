# frozen_string_literal: true

class UserBenefit < ApplicationRecord
  belongs_to :benefit
  belongs_to :user
  belongs_to :company
  has_many :applied_benefits, dependent: :nullify
  validates :amount, presence: { message: I18n.t('user_benefit.validation.presence.') }, numericality: true
end
