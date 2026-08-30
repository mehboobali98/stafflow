class Setting < ApplicationRecord
  belongs_to :company
  validates :tax_rate,
            numericality: { greater_than: MIN_TAX_RATE, less_than_or_equal_to: MAX_TAX_RATE }
  validate :leave_reset_date_valid?, on: :update

  private

  def leave_reset_date_valid?
    return true if leave_resets_at.blank?
    return true if leave_resets_at.to_date > Date.today

    errors.add(:base, I18n.t('leave_error'))
    false
  end
end
