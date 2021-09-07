# frozen_string_literal: true

class Benefit < ApplicationRecord
  has_many :user_benefits
  has_many :applied_benefits
  belongs_to :company
  validates :name, uniqueness: true
  validates :name, presence: { message: I18n.t('benefit.validation.presence.') }
  validates :benefit_type, presence: { message: I18n.t('benefit.validation.presence.') }
end
