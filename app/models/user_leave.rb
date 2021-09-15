class UserLeave < ApplicationRecord
  belongs_to :user
  belongs_to :leave
  has_many :applied_leaves, dependent: :nullify
  validates :total_count, :remaining_count, presence: true
  validates :total_count, :remaining_count, numericality: { in: VALID_RANGE, only_integer: true }

  def self.add_user_leave(user_id, user_leave_params)
    ActiveRecord::Base.transaction do
      user_leave_params.values.first.each_value do |value|
        UserLeave.create!(value.merge(user_id: user_id, remaining_count: value[:total_count])) unless UserLeave.exists?(
          user_id: user_id, leave_id: value[:leave_id]
        )
      end
      true
    rescue ActiveRecord::RecordInvalid
      false
    end
  end

  def self.get_user_leaves(user_id)
    UserLeave.joins(:leave).select('user_leaves.id, leaves.name').where(
      'user_id = ? AND remaining_count > ?', user_id, 0
    )
  end

  def self.get_all_user_leaves(user_id)
    UserLeave.joins(:leave).select('user_leaves.id, leaves.name').where(
      'user_id = ? ', user_id
    )
  end
end
