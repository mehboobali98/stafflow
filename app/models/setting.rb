class Setting < ApplicationRecord
  belongs_to :company
  validates :tax_rate,
            numericality: { only_float: true, greater_than: MIN_TAX_RATE, less_than_or_equal_to: MAX_TAX_RATE }
  validate :leave_reset_date_valid?, on: :update

  private

  def leave_reset_date_valid?
    return true if DateTime.parse(leave_resets_at.to_s) > Date.today

    errors.add(:base, I18n.t('leave_error'))
    false
  end
end
