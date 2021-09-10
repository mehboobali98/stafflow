class UserLeave < ApplicationRecord
  belongs_to :user
  belongs_to :leave
  has_many :applied_leaves
  validates :total_count, :remaining_count, presence: true
  validates :total_count, :remaining_count, numericality: { only_integer: true }

  def self.add_user_leave(user_id, user_leave_params)
    ActiveRecord::Base.transaction do
      user_leave_params.values.first.each_value do |value|
        UserLeave.create!(value.merge(user_id: user_id, remaining_count: value[:total_count]))
      end
      true
    rescue ActiveRecord::RecordInvalid
      false
    end
  end
end
