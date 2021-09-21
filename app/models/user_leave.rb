class UserLeave < ApplicationRecord
  belongs_to :user
  belongs_to :leave
  belongs_to :company
  has_many :applied_leaves, dependent: :nullify
  validates_uniqueness_of :user_id, scope: :leave_id, message: I18n.t('user_leave.messages.duplicate_error')
  validates :total_count, :remaining_count, presence: true
  validates :total_count, :remaining_count, numericality: { in: VALID_LEAVE_RANGE }
  validate :validate_user_leave_count, on: :update

  #     options = {}
  #     leave = {
  #         6: {"leave_id" => 6, "total_count" => 30.0},
  #         7: {"leave_id" => 7, "total_count" => 40.0}
  #       .
  #       .
  #       }

  def self.add_user_leaves(user, options = {})
    return false if options.empty?

    ActiveRecord::Base.transaction do
      # options[:leave].each_value
      options.values.first.each_value do |value|
        user.user_leaves.build(value.merge(remaining_count: value[:total_count]))
        user.save!
      end
      true
    rescue ActiveRecord::RecordInvalid
      false
    end
  end

  def validate_user_leave_count
    return true unless total_count < remaining_count

    errors.add(:total_leave_count, I18n.t('user_leave.messages.failure.total_leave_count'))
    false
  end
end
