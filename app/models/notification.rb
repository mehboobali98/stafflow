class Notification < ApplicationRecord
  belongs_to :sender, class_name: :User, foreign_key: :sender_id
  belongs_to :recipient, class_name: :User, foreign_key: :recipient_id
  STATUS = { unread: 0, read: 1 }.freeze
end
