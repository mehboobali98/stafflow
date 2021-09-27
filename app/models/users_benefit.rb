# frozen_string_literal: true

class UsersBenefit < ApplicationRecord
  sequenceid :company, :users_benefits
  belongs_to :benefit
  belongs_to :user
  belongs_to :company
  has_many :applied_benefits, dependent: :nullify
  validates :amount, presence: { message: I18n.t('users_benefit.validation.presence.') },
                     numericality: { only_float: true, less_than: FLOAT_MAX, greater_than: FLOAT_MIN, other_than: 0,
                     numericality: { only_float: true, other_than: 0,
                                     message: I18n.t('benefit.validation.zero_check') }
end
