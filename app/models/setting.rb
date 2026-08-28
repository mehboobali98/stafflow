class Setting < ApplicationRecord
  belongs_to :company
  validates :tax_rate,
            numericality: { only_float: true, greater_than: MIN_TAX_RATE, less_than_or_equal_to: MAX_TAX_RATE }
  validate :leave_reset_date_valid?, on: :update

  private

  # The column is nullable and starts unset, so "no reset scheduled" is a valid
  # state and only a date that is actually present has to be in the future.
  # Parsing the attribute back out of its own to_s raised Date::Error on nil,
  # which turned the settings form on a new company into a 500.
  def leave_reset_date_valid?
    return true if leave_resets_at.blank?
    return true if leave_resets_at.to_date > Date.today

    errors.add(:base, I18n.t('leave_error'))
    false
  end
end
