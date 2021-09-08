class AppliedLeave < ApplicationRecord
  include ActiveModel::Transitions
  belongs_to :user_leave
  scope :remaining_leave_count, -> { where('remaining_count>0') }

  state_machine do
    state :pending # first one is initial state
    state :accepted
    state :rejected

    event :request_accepted do
      transitions to: :accepted, from: :pending
    end
    event :request_rejected do
      transitions to: :rejected, from: :pending
    end
  end
end
