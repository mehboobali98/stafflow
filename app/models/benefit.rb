# frozen_string_literal: true

class Benefit < ApplicationRecord
  sequenceid :company, :benefits
  has_many :users_benefits, dependent: :nullify
  has_many :applied_benefits
  belongs_to :company
  validates :name, uniqueness: true
  validates :name, presence: { message: I18n.t('benefit.validation.presence') }
  validates :benefit_type, presence: { message: I18n.t('benefit.validation.presence') },
                           inclusion: { in: ['Annually', 'Monthly', 'One Time'],
                                        message: I18n.t('benefit.validation.benefit_type_uniqueness') }
end
