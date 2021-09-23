# frozen_string_literal: true

class Benefit < ApplicationRecord
  sequenceid :company, :benefits
  has_many :users_benefits, dependent: :restrict_with_error
  has_many :applied_benefits, dependent: :restrict_with_error
  belongs_to :company
  validates :name, uniqueness: true
  validates :name, presence: { message: I18n.t('benefit.validation.presence') }
end
