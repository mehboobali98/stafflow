class UserLeave < ApplicationRecord
  belongs_to :user
  belongs_to :leave
  belongs_to :company
  has_many :applied_leaves, dependent: :nullify
  validates_uniqueness_of :user_id, scope: :leave_id, message: I18n.t('user_leave.messages.duplicate_error')
  validates :total_count, :remaining_count, presence: true
  validates :total_count, :remaining_count, numericality: { greater_than: MIN_LEAVE_COUNT, less_than: MAX_LEAVE_COUNT }
  before_update :set_remaining_leave_count
  before_destroy :check_pending_leaves?, prepend: true

  #     user_leave_values = {}
  #     leave = {
  #         6: {"leave_id" => 6, "total_count" => 30.0},
  #         7: {"leave_id" => 7, "total_count" => 40.0}
  #          .
  #          .
  #       }
  def self.create_user_leaves(user, user_leave_values = {})
    return false if user_leave_values.blank?

    ActiveRecord::Base.transaction do
      user_leave_values[:leave].each_value do |leave_values|
        user.user_leaves.build(leave_values.merge(remaining_count: leave_values[:total_count]))
        user.save!
      end
      true
    rescue ActiveRecord::RecordInvalid
      false
    end
  end

  def check_pending_leaves?
    return true unless applied_leaves.where(state: 'pending').exists?

    errors.add(:base, I18n.t('user_leave.messages.failure.applied_leave_exists'))
    throw(:abort)
  end

  def count_available?(leave_count)
    return true if leave_count < remaining_count

    false
  end

  def set_remaining_leave_count
    applied_leave_count = total_count_was - remaining_count
    self.remaining_count = total_count - applied_leave_count
    self.remaining_count = 0 if remaining_count.negative?
  end
end
