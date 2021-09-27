# frozen_string_literal: true

class Benefit < ApplicationRecord
  sequenceid :company, :benefits
  has_many :users_benefits, dependent: :restrict_with_error
  has_many :applied_benefits, dependent: :restrict_with_error
  belongs_to :company
  validates :name,
            uniqueness: { scope: :company_id, case_sensitive: false,
                          message: I18n.t('benefit.validation.duplicate_error') }
  validates :name, presence: { message: I18n.t('benefit.validation.presence') }
  validates :name, format: { with: /\A[a-z A-Z]+\z/, message: I18n.t('benefit.validation.benefit_name') }
  validates :default_amount, presence: { message: I18n.t('users_benefit.validation.presence.') },
                             numericality: { only_float: true, less_than: FLOAT_MAX, greater_than: FLOAT_MIN }
  validates :default_amount, numericality: { other_than: 0, message: I18n.t('benefit.validation.zero_check') }
end
