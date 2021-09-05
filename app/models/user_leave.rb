class UserLeave < ApplicationRecord
  belongs_to :user
  belongs_to :leave
  has_many :applied_leaves
end
