class UserLeave < ApplicationRecord
  belongs_to :user
  belongs_to :leave
  has_many :applied_leaves, dependent: :nullify
  validates_uniqueness_of :user_id, scope: :leave_id
  validates :total_count, :remaining_count, presence: true
  validates :total_count, :remaining_count, numericality: { in: VALID_RANGE }
  validate :validate_user_leave_count, on: :update

  def self.add_user_leave(user_id, user_leave_params)
    ActiveRecord::Base.transaction do
      user_leave_params.values.first.each_value do |value|
        create!(value.merge(user_id: user_id, remaining_count: value[:total_count])) unless UserLeave.exists?(
          user_id: user_id, leave_id: value[:leave_id]
        )
      end
      true
    rescue ActiveRecord::RecordInvalid
      false
    end
  end

  def self.get_user_leaves(user_id)
    joins(:leave).select('user_leaves.id, leaves.name').where(
      'user_id = ? AND remaining_count > ?', user_id, 0
    )
  end

  def self.get_all_user_leaves(user_id)
    joins(:leave).select('user_leaves.id, leaves.name').where(
      'user_id = ? ', user_id
    )
  end

  def validate_user_leave_count
    return true unless total_count < remaining_count

    errors.add(:total_leave_count, I18n.t('user_leave.messages.error.total_leave_count'))
    false
  end
end
