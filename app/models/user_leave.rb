class UserLeave < ApplicationRecord
  belongs_to :user
  belongs_to :leavetype
  has_many :applied_leaves
end
